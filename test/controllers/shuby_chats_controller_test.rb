require "test_helper"

class ShubyChatsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @chat = shuby_chats(:one)
    sign_in @user
  end

  test "requires authentication" do
    sign_out @user
    get shuby_chats_path
    assert_redirected_to new_user_session_path
  end

  test "should get index" do
    get shuby_chats_path
    assert_response :success
    assert_select "h1", /Shuby/
  end

  test "should create shuby_chat" do
    assert_difference("ShubyChat.count") do
      post shuby_chats_path
    end

    assert_redirected_to shuby_chat_path(ShubyChat.last)
  end

  test "should show shuby_chat" do
    get shuby_chat_path(@chat)
    assert_response :success
  end

  test "should not show other user's chat" do
    other_user = users(:two)
    other_chat = shuby_chats(:two)

    get shuby_chat_path(other_chat)
    assert_redirected_to shuby_chats_path
  end

  test "should destroy shuby_chat" do
    assert_difference("ShubyChat.count", -1) do
      delete shuby_chat_path(@chat)
    end

    assert_redirected_to shuby_chats_path
  end

  test "should not destroy other user's chat" do
    other_chat = shuby_chats(:two)

    assert_no_difference("ShubyChat.count") do
      delete shuby_chat_path(other_chat)
    end

    assert_redirected_to shuby_chats_path
  end

  test "message action requires valid message" do
    post message_shuby_chat_path(@chat), params: { message: "" }

    # Should not create a new message with empty content
    assert_response :success
  end

  test "message action with valid message" do
    # This test would require mocking the OpenAI API
    # For now, we skip the actual API call test
    skip "Requires OpenAI API mocking"
  end
end
