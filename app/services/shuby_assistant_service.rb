# frozen_string_literal: true

require "net/http"
require "json"

# Service for managing Shuby AI chat assistant interactions using OpenAI Responses API
#
# @example Basic usage with streaming
#   service = ShubyAssistantService.new(shuby_chat)
#   service.ask_streaming("What are the milestones at 6 months?") do |event|
#     case event[:type]
#     when :delta then print event[:content]
#     when :citations then puts "Citations: #{event[:citations]}"
#     when :completed then puts "Done!"
#     end
#   end
#
class ShubyAssistantService
  # Italian system prompt for Shuby - child development expert (0-36 months)
  SYSTEM_PROMPT = <<~PROMPT
     Shuby, un'assistente esperta in sviluppo infantile (0-36 mesi) che supporta genitori con consigli evidence-based.

    STILE COMUNICATIVO:
    - Usa un tono empatico, caldo e rassicurante
    - Linguaggio chiaro e accessibile (evita gergo medico eccessivo)
    - Rispondi con professionalità ma umanità

    FORMATTAZIONE (Markdown):
    - Usa **grassetto** per concetti chiave e età specifiche
    - Usa ## Titoli per organizzare risposte lunghe
    - Usa liste puntate per caratteristiche/benefici:
      * Punto 1
      * Punto 2
    - Usa liste numerate per step sequenziali
    - Usa > citazioni per note importanti
    - Usa tabelle per confronti per età:

    | Età | Movimento | Sonno | Schermi |
    |-----|-----------|-------|---------|
    | 0-11 mesi | ≥30 min tummy time | 12-16h | Sconsigliati |

    CONTENUTO:
    - Organizza risposte per fasce d'età (0-11 mesi, 12-23 mesi, 24-36 mesi) quando rilevante
    - Cita sempre le fonti dalla knowledge base
    - Enfatizza l'importanza della personalizzazione ("ogni bambino è unico")
    - Includi SEMPRE disclaimer: "⚕️ Consulta sempre il pediatra per situazioni specifiche del tuo bambino"

    LINGUAGGIO POSITIVO:
    - Usa "il tuo bambino" invece di "un bambino"
    - Usa "può" invece di "deve"
    - Celebra i piccoli progressi
    - Rassicura i genitori sulle variazioni normali
  PROMPT

  # Default model to use - Single source of truth for model name
  DEFAULT_MODEL = "gpt-5-mini"

  # Display name for the model (used in UI)
  MODEL_DISPLAY_NAME = "GPT-5 Mini"

  # OpenAI API endpoint for Responses API
  OPENAI_RESPONSES_URL = "https://api.openai.com/v1/responses"

  # Regex pattern to match OpenAI citation markers like 【filecite...】, 【turn0file1】, etc.
  CITATION_MARKER_PATTERN = /【[^】]*】/

  # Initialize the service with a ShubyChat record
  #
  # @param shuby_chat [ShubyChat] The chat record
  def initialize(shuby_chat)
    @shuby_chat = shuby_chat
  end

  # Sends a message and streams the response using OpenAI Responses API
  #
  # @param message [String] The user's message
  # @yield [Hash] Each event with :type (:delta, :citations, :completed, :error)
  # @return [Hash] The complete response info including response_id
  def ask_streaming(message, &block)
    accumulated_text = ""
    citations = []
    file_search_results = []
    response_id = nil
    input_tokens = 0
    output_tokens = 0

    begin
      stream_openai_response(message) do |event_data|
        event_type = event_data["type"]

        case event_type
        when "response.output_text.delta"
          delta = event_data["delta"]
          if delta.present?
            accumulated_text += delta
            # Strip citation markers before sending to UI
            cleaned_delta = strip_citation_markers(delta)
            block&.call({type: :delta, content: cleaned_delta}) if cleaned_delta.present?
          end

        when "response.file_search_call.results"
          # Collect file search results for citations
          results = event_data["results"] || []
          results.each do |result|
            file_name = result["file_name"] || result["filename"] || "Documento"
            text = result["text"]

            unless citations.any? { |c| c[:file_name] == file_name }
              citations << {file_name: file_name}
            end
            if text.present?
              file_search_results << {file_name: file_name, text: text.truncate(500)}
            end
          end

        when "response.output_text.annotation.added"
          # Handle inline annotations/citations
          annotation = event_data["annotation"] || {}
          file_name = annotation["filename"]
          if file_name.present? && !citations.any? { |c| c[:file_name] == file_name }
            citations << {file_name: file_name}
          end

        when "response.completed"
          response = event_data["response"] || {}
          response_id = response["id"]

          # Extract usage info
          usage = response["usage"] || {}
          input_tokens = usage["input_tokens"] || 0
          output_tokens = usage["output_tokens"] || 0
        end
      end
    rescue => e
      Rails.logger.error("OpenAI Streaming Error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      block&.call({type: :error, message: e.message})
      raise e
    end

    # Store the response_id for conversation context
    @shuby_chat.update(previous_response_id: response_id) if response_id

    # Clean citation markers from accumulated text before saving
    cleaned_content = strip_citation_markers(accumulated_text)

    # Save the assistant message
    assistant_message = @shuby_chat.messages.create!(
      role: "assistant",
      content: cleaned_content,
      model_id: DEFAULT_MODEL,
      input_tokens: input_tokens,
      output_tokens: output_tokens
    )

    # Save citations as tool call if any
    if citations.any?
      tool_call = assistant_message.tool_calls.new(
        tool_call_id: "file_search_#{SecureRandom.hex(8)}",
        name: "file_search",
        arguments: {query: message}
      )
      # Use write_attribute to store in the result JSON column directly
      # (bypassing the has_one :result association from acts_as_tool_call)
      tool_call.write_attribute(:result, {citations: citations, snippets: file_search_results})
      tool_call.save!
    end

    # Yield final events
    block.call({type: :citations, citations: citations}) if block && citations.any?
    block&.call({
      type: :completed,
      content: cleaned_content,
      citations: citations,
      message: assistant_message
    })

    {response_id: response_id, content: cleaned_content, citations: citations, message: assistant_message}
  end

  # Legacy ask method for non-streaming (falls back to streaming but waits)
  #
  # @param message [String] The user's message
  # @return [ShubyMessage] The complete response message
  def ask(message)
    result = nil
    ask_streaming(message) do |event|
      result = event if event[:type] == :completed
    end
    result&.dig(:message)
  end

  # Strips OpenAI citation markers from text content
  # These markers like 【filecite...】, 【turn0file1】 are inserted by the API
  # but should not be displayed to users.
  #
  # @param text [String] The text to clean
  # @return [String] Text with citation markers removed
  def strip_citation_markers(text)
    return text if text.blank?

    text.gsub(CITATION_MARKER_PATTERN, "")
  end

  # Updates the chat title based on the first message
  #
  # @return [void]
  def update_title_if_needed
    return if @shuby_chat.title.present?
    return if @shuby_chat.messages.user_messages.empty?

    first_message = @shuby_chat.messages.user_messages.first
    return unless first_message&.content

    # Generate a short title from the first message
    title = first_message.content.truncate(50)
    @shuby_chat.update(title: title)
  end

  private

  # Streams the OpenAI Responses API with Server-Sent Events
  #
  # @param message [String] The user's message
  # @yield [Hash] Each parsed SSE event data
  def stream_openai_response(message)
    uri = URI(OPENAI_RESPONSES_URL)
    request = build_http_request(uri, message)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 120

    http.request(request) do |response|
      unless response.code == "200"
        error_body = response.body
        raise "OpenAI API error (#{response.code}): #{error_body}"
      end

      buffer = ""
      response.read_body do |chunk|
        buffer += chunk

        # Parse SSE format: data: {...}\n\n
        while (match = buffer.match(/data: (.+?)\n\n/m))
          buffer = match.post_match
          data_str = match[1].strip

          next if data_str == "[DONE]"

          begin
            event_data = JSON.parse(data_str)
            yield(event_data)
          rescue JSON::ParserError => e
            Rails.logger.warn("Failed to parse SSE data: #{data_str}, error: #{e.message}")
          end
        end
      end
    end
  end

  # Builds the HTTP request for OpenAI Responses API
  #
  # @param uri [URI] The API endpoint
  # @param message [String] The user's message
  # @return [Net::HTTP::Post] The configured HTTP request
  def build_http_request(uri, message)
    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{ENV["OPENAI_API_KEY"]}"

    body = {
      model: @shuby_chat.model || DEFAULT_MODEL,
      input: message,
      instructions: SYSTEM_PROMPT,
      stream: true,
      store: true
    }

    # Add file_search tool only if vector store is configured
    vector_store_id = ENV["VECTOR_STORE_ID"]
    if vector_store_id.present?
      body[:tools] = [
        {
          type: "file_search",
          vector_store_ids: [vector_store_id]
        }
      ]
      body[:include] = ["file_search_call.results"]
    end

    # Add conversation context if available
    if @shuby_chat.previous_response_id.present?
      body[:previous_response_id] = @shuby_chat.previous_response_id
    end

    request.body = body.to_json
    request
  end

  class << self
    # Creates a new chat for a user and returns the service
    #
    # @param user [User] The user
    # @param model [String] The model to use
    # @return [ShubyAssistantService] The service instance
    def create_for_user(user, model: DEFAULT_MODEL)
      chat = user.shuby_chats.create!(model: model)
      new(chat)
    end
  end
end
