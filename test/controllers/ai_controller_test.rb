require "test_helper"

class AiControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post session_path, params: { email_address: @user.email_address, password: "password" }
    @goal = Goal.create!(user: @user, title: "Meta SMART de Exemplo", status: :active)
    ENV["GEMINI_API_KEY"] = "fake_test_key"
  end

  test "should get index" do
    get ai_dashboard_path
    assert_response :success
  end

  test "should analyze tasks" do
    stub_service(Ai::TaskAnalysisService, :call, "Relatório de Análise") do
      post analyze_tasks_ai_path, params: { period_days: 30 }
      assert_response :success
    end
  end

  test "should suggest goals" do
    mock_suggestions = [
      { "title" => "Meta Sugerida", "description" => "Desc", "target_date" => "2026-09-01" }
    ]

    stub_service(Ai::GoalSuggestionService, :suggest_goals, mock_suggestions) do
      post suggest_goals_ai_path
      assert_response :success
    end
  end

  test "should generate smart fields for goal form" do
    mock_fields = {
      "smart_specific" => "Especificação",
      "smart_measurable" => "Métrica"
    }

    stub_service(Ai::GoalSuggestionService, :generate_smart_fields, mock_fields) do
      post generate_smart_fields_ai_path, params: { title: "Melhorar Assertividade" }
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal "Especificação", json["smart_specific"]
    end
  end

  test "should accept suggested goal" do
    assert_difference("Goal.count", 1) do
      post accept_goal_ai_path, params: {
        goal: {
          title: "Meta Aceita da IA",
          description: "Descrição",
          smart_specific: "Específico"
        }
      }
    end

    assert_redirected_to goals_path
  end

  test "should decompose goal into tasks" do
    mock_tasks = [ Task.new(title: "Tarefa Gerada") ]

    stub_service(Ai::GoalDecomposerService, :call, mock_tasks) do
      post decompose_goal_ai_path, params: { goal_id: @goal.id }
      assert_redirected_to goal_path(@goal)
    end
  end

  private

  def stub_service(target_class, method_name, result)
    klass = target_class.singleton_class
    original = target_class.method(method_name)
    klass.send(:define_method, method_name) { |*args, **kwargs| result }
    yield
  ensure
    klass.send(:define_method, method_name, original)
  end
end
