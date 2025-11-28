# frozen_string_literal: true

# Migration to create tables for Shuby chat assistant
# Uses RubyLLM's acts_as_chat, acts_as_message, and acts_as_tool_call
class CreateShubyTables < ActiveRecord::Migration[8.0]
  def change
    # Conversations table
    create_table :shuby_chats do |t|
      t.references :user, null: false, foreign_key: true
      t.string :model, null: false, default: "gpt-5-mini"
      t.string :title

      t.timestamps
    end

    # Messages table
    create_table :shuby_messages do |t|
      t.references :shuby_chat, null: false, foreign_key: true
      t.string :role, null: false
      t.text :content
      t.string :model_id
      t.integer :input_tokens
      t.integer :output_tokens

      t.timestamps
    end

    # Tool calls table (for file_search results and citations)
    create_table :shuby_tool_calls do |t|
      t.references :shuby_message, null: false, foreign_key: true
      t.string :tool_call_id, null: false
      t.string :name, null: false
      t.json :arguments, default: {}
      t.json :result

      t.timestamps
    end

    add_index :shuby_chats, :created_at
    add_index :shuby_messages, :role
    add_index :shuby_tool_calls, :tool_call_id
  end
end
