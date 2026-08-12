require "test_helper"

class MbtiProfileTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "valid profile" do
    profile = MbtiProfile.new(user: @user, final_type: "INTJ", temperament_group: "Analistas", dominant_function: "Ni")
    assert profile.valid?
  end

  test "invalid without final_type" do
    profile = MbtiProfile.new(user: @user)
    assert_not profile.valid?
    assert profile.errors[:final_type].any?
  end
end
