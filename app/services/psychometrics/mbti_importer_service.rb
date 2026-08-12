module Psychometrics
  class MbtiImporterService
    def self.call(user, json_data)
      data = json_data.is_a?(String) ? JSON.parse(json_data) : json_data
      profile_data = data.dig("profile") || {}
      dichotomies = profile_data.dig("dichotomies") || {}
      hierarchy = profile_data.dig("cognitive_hierarchy") || {}

      profile = user.mbti_profile || user.build_mbti_profile
      profile.assign_attributes(
        assessment_id: data["assessment_id"],
        final_type: profile_data["final_type"],
        temperament_group: profile_data["temperament_group"],
        temperament_code: profile_data["temperament_code"],
        ei_winner: dichotomies.dig("E_I", "winner"),
        ei_pci: dichotomies.dig("E_I", "pci_percentage"),
        sn_winner: dichotomies.dig("S_N", "winner"),
        sn_pci: dichotomies.dig("S_N", "pci_percentage"),
        tf_winner: dichotomies.dig("T_F", "winner"),
        tf_pci: dichotomies.dig("T_F", "pci_percentage"),
        jp_winner: dichotomies.dig("J_P", "winner"),
        jp_pci: dichotomies.dig("J_P", "pci_percentage"),
        dominant_function: hierarchy.dig("dominant", "code"),
        auxiliary_function: hierarchy.dig("auxiliary", "code"),
        tertiary_function: hierarchy.dig("tertiary", "code"),
        inferior_function: hierarchy.dig("inferior", "code"),
        imported_at: Time.current
      )
      profile.save!
      profile
    end
  end
end
