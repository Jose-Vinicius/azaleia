require "test_helper"

class GoalSuggestionServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    ENV["GEMINI_API_KEY"] = "fake_test_key"
  end

  test "suggest_goals returns parsed array of goals" do
    mock_json = {
      "goals" => [
        {
          "title" => "Meta Sugerida 1",
          "description" => "Descrição",
          "smart_specific" => "Específico",
          "target_days" => 30
        }
      ]
    }

    stub_gemini(mock_json) do
      suggestions = Ai::GoalSuggestionService.suggest_goals(@user)
      assert_equal 1, suggestions.count
      assert_equal "Meta Sugerida 1", suggestions.first["title"]
    end
  end

  test "generate_smart_fields returns parsed object for a goal title" do
    mock_json = {
      "smart_specific" => "Detalhamento específico",
      "smart_measurable" => "Métrica em %",
      "target_days" => 60
    }

    stub_gemini(mock_json) do
      fields = Ai::GoalSuggestionService.generate_smart_fields(@user, title: "Aumentar Foco")
      assert_equal "Detalhamento específico", fields["smart_specific"]
      assert_equal "Métrica em %", fields["smart_measurable"]
    end
  end

  private

  def stub_gemini(result)
    klass = Ai::GeminiClient.singleton_class
    original = Ai::GeminiClient.method(:generate_content)
    klass.send(:define_method, :generate_content) { |*args, **kwargs| result }
    yield
  ensure
    klass.send(:define_method, :generate_content, original)
  end
end
