# frozen_string_literal: true

# Adds shuby_tool_call_id to shuby_messages for tool response messages
# When RubyLLM's acts_as_message creates a "tool" role message (responding to a tool call),
# it needs to reference which tool call it's responding to via this foreign key.
class AddShubyToolCallIdToShubyMessages < ActiveRecord::Migration[8.1]
  def change
    add_reference :shuby_messages, :shuby_tool_call, null: true, foreign_key: true
  end
end
