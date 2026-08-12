require "test_helper"

class PsychometricsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post session_path, params: { email_address: @user.email_address, password: "password" }
  end

  test "should get show" do
    get psychometrics_path
    assert_response :success
  end

  test "should import eqi from json params" do
    payload = {
      assessment_id: "test-eqi",
      scores: {
        total_eq: 110,
        subscales: {
          reality_testing: { standard_score: 80 }
        }
      }
    }.to_json

    post import_eqi_psychometrics_path, params: { json_data: payload }
    assert_redirected_to psychometrics_path
    assert_equal 110, @user.reload.eqi_profile.total_eq
  end

  test "should import mbti from json params" do
    payload = {
      assessment_id: "test-mbti",
      profile: {
        final_type: "INTJ",
        temperament_group: "Analistas"
      }
    }.to_json

    post import_mbti_psychometrics_path, params: { json_data: payload }
    assert_redirected_to psychometrics_path
    assert_equal "INTJ", @user.reload.mbti_profile.final_type
  end
end
