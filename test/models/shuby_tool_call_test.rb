require "test_helper"

class ShubyToolCallTest < ActiveSupport::TestCase
  setup do
    @tool_call = shuby_tool_calls(:file_search_call)
    @message = shuby_messages(:assistant_message)
  end

  test "valid tool call" do
    assert @tool_call.valid?
  end

  test "invalid without tool_call_id" do
    @tool_call.tool_call_id = nil
    refute @tool_call.valid?
    assert_not_nil @tool_call.errors[:tool_call_id]
  end

  test "invalid without name" do
    @tool_call.name = nil
    refute @tool_call.valid?
    assert_not_nil @tool_call.errors[:name]
  end

  test "belongs to shuby_message" do
    assert_respond_to @tool_call, :shuby_message
    assert_equal @message, @tool_call.shuby_message
  end

  test "file_search? returns true for file_search tool calls" do
    assert @tool_call.file_search?
  end

  test "file_search? returns false for other tool calls" do
    @tool_call.name = "other_tool"
    refute @tool_call.file_search?
  end

  test "search_query returns query from arguments" do
    assert_equal "milestones 6 months", @tool_call.search_query
  end

  test "citations returns citations from result" do
    citations = @tool_call.citations
    assert_kind_of Array, citations
    assert citations.any?
    assert_equal "Neurosviluppo_0-12.docx", citations.first["file_name"]
  end

  test "snippets returns snippets from result" do
    snippets = @tool_call.snippets
    assert_kind_of Array, snippets
    assert snippets.any?
  end

  test "file_searches scope" do
    tool_calls = ShubyToolCall.file_searches
    tool_calls.each do |tc|
      assert tc.file_search?
    end
  end

  test "citations returns empty array when result is nil" do
    @tool_call.result = nil
    assert_equal [], @tool_call.citations
  end

  test "snippets returns empty array when result is nil" do
    @tool_call.result = nil
    assert_equal [], @tool_call.snippets
  end
end
