# frozen_string_literal: true

# Model for Shuby tool calls (file_search results and citations)
#
# @example
#   tool_call = message.tool_calls.create!(
#     tool_call_id: "call_123",
#     name: "file_search",
#     arguments: { query: "child development" },
#     result: { citations: [...] }
#   )
#
class ShubyToolCall < ApplicationRecord
  # Use RubyLLM legacy API
  # This creates: belongs_to :message (with ShubyMessage, shuby_message_id foreign key)
  #               has_one :result (with ShubyMessage, shuby_tool_call_id foreign key)
  acts_as_tool_call message_class: "ShubyMessage",
                    message_foreign_key: "shuby_message_id",
                    result_foreign_key: "shuby_tool_call_id"

  # Alias for code that uses shuby_message instead of message
  alias_method :shuby_message, :message

  validates :tool_call_id, presence: true
  validates :name, presence: true

  scope :file_searches, -> { where(name: "file_search") }

  # Checks if this is a file_search tool call
  #
  # @return [Boolean]
  def file_search?
    name == "file_search"
  end

  # Returns the search query used
  #
  # @return [String, nil]
  def search_query
    arguments&.dig("query")
  end

  # Returns citations from the result JSON column
  #
  # @return [Array<Hash>]
  def citations
    # Use read_attribute to access the result column directly
    # (not the :result association created by acts_as_tool_call)
    result_data&.dig("citations") || []
  end

  # Returns snippets from the search result JSON column
  #
  # @return [Array<Hash>]
  def snippets
    result_data&.dig("snippets") || []
  end

  # Access the result JSON column directly (avoiding conflict with :result association)
  #
  # @return [Hash, nil] The result JSON data
  def result_data
    read_attribute(:result)
  end
end
