require "test_helper"

class EqiImporterServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @json_payload = {
      schema_version: "1.0",
      source: "ametista",
      assessment_id: "uuid-do-teste-eqi",
      completed_at: "2026-08-11T10:00:00Z",
      user: { email: "usuario@exemplo.com", name: "Nome do Usuário" },
      scores: {
        total_eq: 108,
        validity: { is_valid: true, inconsistency_index: 3 },
        wellbeing: { status: "Balanced", happiness_score: 112 },
        subscales: {
          self_regard: { standard_score: 110, threshold: "medium" },
          self_actualization: { standard_score: 115, threshold: "high" },
          emotional_self_awareness: { standard_score: 95, threshold: "medium" },
          emotional_expression: { standard_score: 82, threshold: "low" },
          assertiveness: { standard_score: 88, threshold: "medium" },
          independence: { standard_score: 105, threshold: "medium" },
          interpersonal_relationships: { standard_score: 90, threshold: "medium" },
          empathy: { standard_score: 102, threshold: "medium" },
          social_responsibility: { standard_score: 100, threshold: "medium" },
          problem_solving: { standard_score: 118, threshold: "high" },
          reality_testing: { standard_score: 80, threshold: "low" },
          impulse_control: { standard_score: 86, threshold: "medium" },
          flexibility: { standard_score: 92, threshold: "medium" },
          stress_tolerance: { standard_score: 104, threshold: "medium" },
          optimism: { standard_score: 122, threshold: "high" }
        }
      }
    }.to_json
  end

  test "imports EQ-i profile correctly from json" do
    profile = Psychometrics::EqiImporterService.call(@user, @json_payload)

    assert profile.persisted?
    assert_equal @user, profile.user
    assert_equal "uuid-do-teste-eqi", profile.assessment_id
    assert_equal 108, profile.total_eq
    assert profile.is_valid
    assert_equal 112, profile.happiness_score
    assert_equal 110, profile.self_regard_score
    assert_equal 115, profile.self_actualization_score
    assert_equal 95, profile.emotional_self_awareness_score
    assert_equal 82, profile.emotional_expression_score
    assert_equal 88, profile.assertiveness_score
    assert_equal 105, profile.independence_score
    assert_equal 90, profile.interpersonal_relationships_score
    assert_equal 102, profile.empathy_score
    assert_equal 100, profile.social_responsibility_score
    assert_equal 118, profile.problem_solving_score
    assert_equal 80, profile.reality_testing_score
    assert_equal 86, profile.impulse_control_score
    assert_equal 92, profile.flexibility_score
    assert_equal 104, profile.stress_tolerance_score
    assert_equal 122, profile.optimism_score
    assert profile.imported_at.present?
  end

  test "updates existing profile on re-import" do
    Psychometrics::EqiImporterService.call(@user, @json_payload)

    updated_payload = JSON.parse(@json_payload)
    updated_payload["scores"]["total_eq"] = 115
    updated_payload["scores"]["subscales"]["reality_testing"]["standard_score"] = 90

    profile = Psychometrics::EqiImporterService.call(@user, updated_payload.to_json)

    assert_equal 1, @user.reload.eqi_profile ? 1 : 0
    assert_equal 115, profile.total_eq
    assert_equal 90, profile.reality_testing_score
  end
end
