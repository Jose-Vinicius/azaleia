require "test_helper"

class MbtiImporterServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @json_payload = {
      schema_version: "1.0",
      source: "bismuto",
      assessment_id: "uuid-do-teste-mbti",
      completed_at: "2026-08-10T14:30:00Z",
      user: { email: "usuario@exemplo.com", name: "Nome do Usuário" },
      profile: {
        final_type: "INTJ",
        temperament_group: "Analistas",
        temperament_code: "NT",
        dichotomies: {
          E_I: { winner: "I", pci_percentage: 78.5, clarity: "Muito clara" },
          S_N: { winner: "N", pci_percentage: 65.0, clarity: "Clara" },
          T_F: { winner: "T", pci_percentage: 82.0, clarity: "Muito clara" },
          J_P: { winner: "J", pci_percentage: 58.0, clarity: "Moderada" }
        },
        cognitive_hierarchy: {
          dominant: { code: "Ni", name: "Intuição Introvertida" },
          auxiliary: { code: "Te", name: "Pensamento Extrovertido" },
          tertiary: { code: "Fi", name: "Sentimento Introvertido" },
          inferior: { code: "Ne", name: "Intuição Extrovertida" }
        }
      }
    }.to_json
  end

  test "imports MBTI profile correctly from json" do
    profile = Psychometrics::MbtiImporterService.call(@user, @json_payload)

    assert profile.persisted?
    assert_equal @user, profile.user
    assert_equal "uuid-do-teste-mbti", profile.assessment_id
    assert_equal "INTJ", profile.final_type
    assert_equal "Analistas", profile.temperament_group
    assert_equal "NT", profile.temperament_code
    assert_equal "I", profile.ei_winner
    assert_equal 78.5, profile.ei_pci.to_f
    assert_equal "N", profile.sn_winner
    assert_equal 65.0, profile.sn_pci.to_f
    assert_equal "T", profile.tf_winner
    assert_equal 82.0, profile.tf_pci.to_f
    assert_equal "J", profile.jp_winner
    assert_equal 58.0, profile.jp_pci.to_f
    assert_equal "Ni", profile.dominant_function
    assert_equal "Te", profile.auxiliary_function
    assert_equal "Fi", profile.tertiary_function
    assert_equal "Ne", profile.inferior_function
    assert profile.imported_at.present?
  end

  test "updates existing mbti profile on re-import" do
    Psychometrics::MbtiImporterService.call(@user, @json_payload)

    updated_payload = JSON.parse(@json_payload)
    updated_payload["profile"]["final_type"] = "ENTJ"

    profile = Psychometrics::MbtiImporterService.call(@user, updated_payload.to_json)

    assert_equal "ENTJ", profile.final_type
  end
end
