# frozen_string_literal: true

namespace :shuby do
  namespace :kb do
    desc "Upload all knowledge base documents to OpenAI Vector Store. Use DIR=path to override default docs/knowledge_base"
    task upload_all: :environment do
      OPENAI_API_URL = "https://api.openai.com/v1"
      SUPPORTED_EXTENSIONS = %w[.pdf .docx .md .txt].freeze

      # Get configuration (ENV takes priority for easier overrides)
      api_key = ENV["OPENAI_API_KEY"] || Rails.application.credentials.dig(:openai, :api_key)
      vector_store_id = ENV["OPENAI_VECTOR_STORE_ID"] || Rails.application.credentials.dig(:openai, :vector_store_id)

      abort "ERROR: OpenAI API key not configured" unless api_key
      abort "ERROR: Vector store ID not configured" unless vector_store_id

      # Get directory path
      dir_path = ENV.fetch("DIR", "docs/knowledge_base")
      dir_path = Rails.root.join(dir_path) unless Pathname.new(dir_path).absolute?

      abort "ERROR: Directory not found: #{dir_path}" unless Dir.exist?(dir_path)

      # Find all supported files recursively
      files = Dir.glob(File.join(dir_path, "**", "*")).select do |path|
        File.file?(path) && SUPPORTED_EXTENSIONS.include?(File.extname(path).downcase)
      end

      if files.empty?
        puts "No files found with extensions: #{SUPPORTED_EXTENSIONS.join(", ")}"
        exit 0
      end

      puts "Found #{files.count} file(s) to process in #{dir_path}"
      puts "-" * 60

      # Setup Faraday connection (no JSON middleware - we parse manually for safety)
      connection = Faraday.new(url: OPENAI_API_URL) do |faraday|
        faraday.request :multipart
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
      end

      # Process each file
      files.each do |file_path|
        filename = File.basename(file_path)
        relative_path = Pathname.new(file_path).relative_path_from(Rails.root).to_s

        # Step 1: List existing files in vector store and find matches by filename
        deleted_count = 0
        existing_files = list_vector_store_files(connection, api_key, vector_store_id)

        matching_files = existing_files.select { |f| f["filename"] == filename }

        # Step 2: Delete matching files
        matching_files.each do |existing_file|
          delete_vector_store_file(connection, api_key, vector_store_id, existing_file["id"])
          deleted_count += 1
        end

        # Step 3: Upload new file to OpenAI
        uploaded_file_id = upload_file(connection, api_key, file_path)

        # Step 4: Attach file to vector store
        attach_file_to_vector_store(connection, api_key, vector_store_id, uploaded_file_id)

        puts "[#{relative_path}] deleted #{deleted_count} old file(s), uploaded new file ID #{uploaded_file_id}."
      end

      puts "-" * 60
      puts "Done! Processed #{files.count} file(s)."
    end

    # Safely parses JSON from response body
    #
    # @param response_body [String, Hash] The response body
    # @return [Hash, nil] Parsed hash or nil on failure
    def safe_parse_json(response_body)
      return response_body if response_body.is_a?(Hash)
      JSON.parse(response_body)
    rescue JSON::ParserError
      nil
    end

    # Extracts error message from response body safely
    #
    # @param response_body [String, Hash] The response body
    # @return [String] The error message or "Unknown error"
    def extract_error_message(response_body)
      parsed = safe_parse_json(response_body)
      return "Unknown error (could not parse response)" unless parsed
      parsed.dig("error", "message") || "Unknown error"
    end

    # Lists all files in a vector store
    #
    # @param connection [Faraday::Connection] The Faraday connection
    # @param api_key [String] OpenAI API key
    # @param vector_store_id [String] The vector store ID
    # @return [Array<Hash>] Array of file objects with id and filename
    def list_vector_store_files(connection, api_key, vector_store_id)
      all_files = []
      after = nil

      loop do
        params = {limit: 100}
        params[:after] = after if after

        response = connection.get("vector_stores/#{vector_store_id}/files") do |req|
          req.headers["Authorization"] = "Bearer #{api_key}"
          req.headers["Content-Type"] = "application/json"
          req.headers["OpenAI-Beta"] = "assistants=v2"
          req.params = params
        end

        unless response.success?
          error_message = extract_error_message(response.body)
          puts "WARNING: Failed to list vector store files: #{error_message}. Treating as no existing files."
          return []
        end

        parsed = safe_parse_json(response.body)
        unless parsed
          puts "WARNING: Could not parse vector store files response. Treating as no existing files."
          return []
        end

        data = parsed["data"] || []
        all_files.concat(data)

        # Handle pagination
        break unless parsed["has_more"]
        after = data.last&.dig("id")
        break unless after
      end

      # Fetch full file details to get filenames
      all_files.filter_map do |vs_file|
        file_id = vs_file["id"]
        file_details = get_file_details(connection, api_key, file_id)
        next unless file_details # Skip files where we couldn't get details

        {
          "id" => file_id,
          "filename" => file_details["filename"]
        }
      end
    end

    # Gets file details from OpenAI Files API
    #
    # @param connection [Faraday::Connection] The Faraday connection
    # @param api_key [String] OpenAI API key
    # @param file_id [String] The file ID
    # @return [Hash, nil] File details or nil on failure
    def get_file_details(connection, api_key, file_id)
      response = connection.get("files/#{file_id}") do |req|
        req.headers["Authorization"] = "Bearer #{api_key}"
        req.headers["Content-Type"] = "application/json"
      end

      unless response.success?
        error_message = extract_error_message(response.body)
        puts "WARNING: Failed to get file details for #{file_id}: #{error_message}. Skipping this file."
        return nil
      end

      parsed = safe_parse_json(response.body)
      unless parsed
        puts "WARNING: Could not parse file details response for #{file_id}. Skipping this file."
        return nil
      end

      parsed
    end

    # Deletes a file from the vector store
    #
    # @param connection [Faraday::Connection] The Faraday connection
    # @param api_key [String] OpenAI API key
    # @param vector_store_id [String] The vector store ID
    # @param file_id [String] The file ID to delete
    def delete_vector_store_file(connection, api_key, vector_store_id, file_id)
      response = connection.delete("vector_stores/#{vector_store_id}/files/#{file_id}") do |req|
        req.headers["Authorization"] = "Bearer #{api_key}"
        req.headers["Content-Type"] = "application/json"
        req.headers["OpenAI-Beta"] = "assistants=v2"
      end

      unless response.success?
        error_message = extract_error_message(response.body)
        abort "ERROR: Failed to delete file #{file_id}: #{error_message}"
      end
    end

    # Uploads a file to OpenAI
    #
    # @param connection [Faraday::Connection] The Faraday connection
    # @param api_key [String] OpenAI API key
    # @param file_path [String] Path to the file to upload
    # @return [String] The uploaded file ID
    def upload_file(connection, api_key, file_path)
      file = Faraday::Multipart::FilePart.new(
        file_path,
        mime_type_for(file_path),
        File.basename(file_path)
      )

      response = connection.post("files") do |req|
        req.headers["Authorization"] = "Bearer #{api_key}"
        req.body = {
          file: file,
          purpose: "assistants"
        }
      end

      unless response.success?
        error_message = extract_error_message(response.body)
        abort "ERROR: Failed to upload file #{file_path}: #{error_message}"
      end

      parsed = safe_parse_json(response.body)
      abort "ERROR: Could not parse upload response for #{file_path}" unless parsed

      parsed["id"]
    end

    # Attaches a file to a vector store
    #
    # @param connection [Faraday::Connection] The Faraday connection
    # @param api_key [String] OpenAI API key
    # @param vector_store_id [String] The vector store ID
    # @param file_id [String] The file ID to attach
    def attach_file_to_vector_store(connection, api_key, vector_store_id, file_id)
      json_connection = Faraday.new(url: OPENAI_API_URL) do |faraday|
        faraday.request :json
        faraday.adapter Faraday.default_adapter
      end

      response = json_connection.post("vector_stores/#{vector_store_id}/files") do |req|
        req.headers["Authorization"] = "Bearer #{api_key}"
        req.headers["Content-Type"] = "application/json"
        req.headers["OpenAI-Beta"] = "assistants=v2"
        req.body = {file_id: file_id}
      end

      unless response.success?
        error_message = extract_error_message(response.body)
        abort "ERROR: Failed to attach file #{file_id} to vector store: #{error_message}"
      end
    end

    # Determines MIME type based on file extension
    #
    # @param file_path [String] Path to the file
    # @return [String] MIME type
    def mime_type_for(file_path)
      case File.extname(file_path).downcase
      when ".pdf"
        "application/pdf"
      when ".docx"
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      when ".md"
        "text/markdown"
      when ".txt"
        "text/plain"
      else
        "application/octet-stream"
      end
    end
  end
end
