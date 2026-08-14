require "test_helper"

class OkrDecomposerServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @okr = Okr.create!(user: @user, title: "OKR Exemplo", quarter: "Q3")
    @kr = @okr.key_results.create!(title: "Resultado-Chave Exemplo")
    ENV["GEMINI_API_KEY"] = "fake_test_key"
  end

  test "decomposes key result into tasks and persists them when create_tasks is true" do
    mock_json = {
      "tasks" => [
        {
          "title" => "Sub-tarefa KR 1",
          "description" => "Passo 1",
          "estimated_minutes" => 30,
          "multiplier_name" => "Estratégico"
        }
      ]
    }

    stub_gemini(mock_json) do
      assert_difference("Task.count", 1) do
        tasks = Ai::OkrDecomposerService.call(@user, @kr, create_tasks: true)
        assert_equal "Sub-tarefa KR 1", tasks.first.title
        assert_equal @kr.id, tasks.first.key_result_id
      end
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
