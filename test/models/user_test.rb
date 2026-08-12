require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "low_eqi_subscales returns subscales below 85" do
    assert_equal [], @user.low_eqi_subscales

    @user.create_eqi_profile!(
      reality_testing_score: 80,
      emotional_expression_score: 82,
      self_regard_score: 110,
      total_eq: 108
    )

    low_scores = @user.low_eqi_subscales
    assert_includes low_scores, "reality_testing_score"
    assert_includes low_scores, "emotional_expression_score"
    assert_not_includes low_scores, "self_regard_score"
  end
end
