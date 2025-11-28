require "test_helper"

class ShubyMessageTest < ActiveSupport::TestCase
  setup do
    @user_message = shuby_messages(:user_message)
    @assistant_message = shuby_messages(:assistant_message)
    @chat = shuby_chats(:one)
  end

  test "valid message" do
    assert @user_message.valid?
    assert @assistant_message.valid?
  end

  test "invalid without role" do
    @user_message.role = nil
    refute @user_message.valid?
    assert_not_nil @user_message.errors[:role]
  end

  test "invalid with wrong role" do
    @user_message.role = "invalid_role"
    refute @user_message.valid?
    assert_not_nil @user_message.errors[:role]
  end

  test "valid roles" do
    ShubyMessage::ROLES.each do |role|
      message = ShubyMessage.new(shuby_chat: @chat, role: role)
      assert message.valid?, "Role #{role} should be valid"
    end
  end

  test "belongs to shuby_chat" do
    assert_respond_to @user_message, :shuby_chat
    assert_equal @chat, @user_message.shuby_chat
  end

  test "user? returns true for user messages" do
    assert @user_message.user?
    refute @user_message.assistant?
  end

  test "assistant? returns true for assistant messages" do
    assert @assistant_message.assistant?
    refute @assistant_message.user?
  end

  test "has many tool_calls" do
    assert_respond_to @assistant_message, :tool_calls
    assert_includes @assistant_message.tool_calls, shuby_tool_calls(:file_search_call)
  end

  test "user_messages scope" do
    messages = @chat.messages.user_messages
    messages.each do |msg|
      assert msg.user?
    end
  end

  test "assistant_messages scope" do
    messages = @chat.messages.assistant_messages
    messages.each do |msg|
      assert msg.assistant?
    end
  end

  test "chronological scope orders by created_at" do
    messages = @chat.messages.chronological
    assert_equal messages, messages.sort_by(&:created_at)
  end

  test "citations returns empty array when no tool calls" do
    @user_message.tool_calls.destroy_all
    assert_equal [], @user_message.citations
  end
end
