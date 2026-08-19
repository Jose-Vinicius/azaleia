require "test_helper"

class AiRequestLogTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "validates action_name and status" do
    log = AiRequestLog.new(user: @user, action_name: "Teste IA", status: "success")
    assert log.valid?

    invalid_log = AiRequestLog.new(user: @user, action_name: nil)
    assert_not invalid_log.valid?
  end

  test "scope recent orders by created_at desc" do
    log1 = AiRequestLog.create!(user: @user, action_name: "Ação 1", created_at: 2.hours.ago)
    log2 = AiRequestLog.create!(user: @user, action_name: "Ação 2", created_at: 1.hour.ago)

    logs = @user.ai_request_logs.recent
    assert_equal log2, logs.first
    assert_equal log1, logs.second
  end
end
