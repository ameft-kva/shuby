# frozen_string_literal: true

class AddPreviousResponseIdToShubyChats < ActiveRecord::Migration[8.1]
  def change
    add_column :shuby_chats, :previous_response_id, :string
  end
end
