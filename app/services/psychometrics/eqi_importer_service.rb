module Psychometrics
  class EqiImporterService
    def self.call(user, json_data)
      data = json_data.is_a?(String) ? JSON.parse(json_data) : json_data
      scores = data.dig("scores") || {}
      subscales = scores.dig("subscales") || {}

      profile = user.eqi_profile || user.build_eqi_profile
      profile.assign_attributes(
        assessment_id: data["assessment_id"],
        total_eq: scores["total_eq"],
        is_valid: scores.dig("validity", "is_valid"),
        happiness_score: scores.dig("wellbeing", "happiness_score"),
        self_regard_score: subscales.dig("self_regard", "standard_score"),
        self_actualization_score: subscales.dig("self_actualization", "standard_score"),
        emotional_self_awareness_score: subscales.dig("emotional_self_awareness", "standard_score"),
        emotional_expression_score: subscales.dig("emotional_expression", "standard_score"),
        assertiveness_score: subscales.dig("assertiveness", "standard_score"),
        independence_score: subscales.dig("independence", "standard_score"),
        interpersonal_relationships_score: subscales.dig("interpersonal_relationships", "standard_score"),
        empathy_score: subscales.dig("empathy", "standard_score"),
        social_responsibility_score: subscales.dig("social_responsibility", "standard_score"),
        problem_solving_score: subscales.dig("problem_solving", "standard_score"),
        reality_testing_score: subscales.dig("reality_testing", "standard_score"),
        impulse_control_score: subscales.dig("impulse_control", "standard_score"),
        flexibility_score: subscales.dig("flexibility", "standard_score"),
        stress_tolerance_score: subscales.dig("stress_tolerance", "standard_score"),
        optimism_score: subscales.dig("optimism", "standard_score"),
        imported_at: Time.current
      )
      profile.save!
      profile
    end
  end
end
