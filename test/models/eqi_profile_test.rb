require "test_helper"

class EqiProfileTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "belongs to user" do
    profile = EqiProfile.new(user: @user, total_eq: 108, reality_testing_score: 80)
    assert profile.valid?
    assert_equal @user, profile.user
  end
end
