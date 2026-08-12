require "test_helper"

class GoalDecomposerServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @goal = Goal.create!(user: @user, title: "Meta para Decompor", status: :active)
    ENV["GEMINI_API_KEY"] = "fake_test_key"
  end

  test "decomposes goal into tasks and persists them when create_tasks is true" do
    mock_json = {
      "tasks" => [
        {
          "title" => "Sub-tarefa 1",
          "description" => "Passo 1",
          "estimated_minutes" => 45,
          "multiplier_name" => "Prioridade"
        }
      ]
    }

    stub_gemini(mock_json) do
      assert_difference("Task.count", 1) do
        tasks = Ai::GoalDecomposerService.call(@user, @goal, create_tasks: true)
        assert_equal "Sub-tarefa 1", tasks.first.title
        assert_equal @goal.id, tasks.first.goal_id
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
