# frozen_string_literal: true

# Model for Shuby chat messages
#
# @example
#   message = chat.messages.create!(role: "user", content: "Hello!")
#
class ShubyMessage < ApplicationRecord
  # Use RubyLLM legacy API
  # This creates: belongs_to :chat (with ShubyChat, shuby_chat_id foreign key)
  #               has_many :tool_calls (with ShubyToolCall)
  acts_as_message chat_class: "ShubyChat",
    chat_foreign_key: "shuby_chat_id",
    tool_call_class: "ShubyToolCall",
    tool_call_foreign_key: "shuby_tool_call_id"

  # Alias for code that uses shuby_chat instead of chat
  alias_method :shuby_chat, :chat
  alias_method :shuby_tool_calls, :tool_calls

  ROLES = %w[user assistant system tool].freeze

  validates :role, presence: true, inclusion: {in: ROLES}

  scope :by_role, ->(role) { where(role: role) }
  scope :user_messages, -> { by_role("user") }
  scope :assistant_messages, -> { by_role("assistant") }
  scope :chronological, -> { order(created_at: :asc) }

  # Checks if this message is from the user
  #
  # @return [Boolean]
  def user?
    role == "user"
  end

  # Checks if this message is from the assistant
  #
  # @return [Boolean]
  def assistant?
    role == "assistant"
  end

  # Checks if this message has tool calls
  #
  # @return [Boolean]
  def has_tool_calls?
    tool_calls.any?
  end

  # Returns citations from tool calls (file_search results)
  #
  # @return [Array<Hash>] Array of citation data
  def citations
    tool_calls.where(name: "file_search").flat_map(&:citations)
  end
end
