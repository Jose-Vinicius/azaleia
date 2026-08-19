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

  test "should analyze tasks via html" do
    stub_service(Ai::TaskAnalysisService, :call, "Relatório de Análise") do
      post analyze_tasks_ai_path, params: { period_days: 30 }, as: :html
      assert_response :success
    end
  end

  test "should analyze tasks via turbo stream" do
    stub_service(Ai::TaskAnalysisService, :call, "Relatório de Análise") do
      post analyze_tasks_ai_path, params: { period_days: 30 }, as: :turbo_stream
      assert_response :success
      assert_match "turbo-stream action=\"update\" target=\"task_analysis_results\"", response.body
    end
  end

  test "should suggest goals via html" do
    mock_suggestions = [
      { "title" => "Meta Sugerida", "description" => "Desc", "target_date" => "2026-09-01" }
    ]

    stub_service(Ai::GoalSuggestionService, :suggest_goals, mock_suggestions) do
      post suggest_goals_ai_path, as: :html
      assert_response :success
    end
  end

  test "should suggest goals via turbo stream" do
    mock_suggestions = [
      { "title" => "Meta Sugerida", "description" => "Desc", "target_date" => "2026-09-01" }
    ]

    stub_service(Ai::GoalSuggestionService, :suggest_goals, mock_suggestions) do
      post suggest_goals_ai_path, as: :turbo_stream
      assert_response :success
      assert_match "turbo-stream action=\"update\" target=\"suggested_goals_results\"", response.body
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

  test "should decompose okr into tasks" do
    okr = Okr.create!(user: @user, title: "OKR Exemplo", quarter: "Q3")
    mock_tasks = [ Task.new(title: "Tarefa OKR Gerada") ]

    stub_service(Ai::OkrDecomposerService, :call, mock_tasks) do
      post decompose_okr_ai_path, params: { okr_id: okr.id }
      assert_redirected_to okrs_path
    end
  end

  test "should decompose key result into tasks" do
    okr = Okr.create!(user: @user, title: "OKR Exemplo", quarter: "Q3")
    kr = okr.key_results.create!(title: "KR Exemplo")
    mock_tasks = [ Task.new(title: "Tarefa KR Gerada") ]

    stub_service(Ai::OkrDecomposerService, :call, mock_tasks) do
      post decompose_key_result_ai_path, params: { key_result_id: kr.id }
      assert_redirected_to okrs_path
    end
  end

  test "should suggest scheduling for open tasks via turbo stream" do
    mock_result = {
      "summary" => "Plano de teste de agendamento",
      "suggestions" => [
        { "task_id" => 1, "suggested_schedule_at" => "2026-08-20T09:00", "reasoning" => "Foco matinal" }
      ]
    }

    stub_service(Ai::OpenTasksSchedulerService, :suggest, mock_result) do
      post schedule_open_tasks_ai_path, as: :turbo_stream
      assert_response :success
      assert_match "turbo-stream action=\"update\" target=\"schedule_preview_results\"", response.body
    end
  end

  test "should apply open tasks schedule" do
    task = Task.create!(user: @user, title: "Tarefa Sem Data", status: "pending")

    post apply_open_tasks_schedule_ai_path, params: {
      schedule: {
        task.id.to_s => { "selected" => "1", "schedule_at" => "2026-08-20T09:00" }
      }
    }, as: :turbo_stream

    assert_response :success
    assert_equal Time.zone.parse("2026-08-20T09:00"), task.reload.schedule_at
  end

  test "should get logs modal" do
    AiRequestLog.create!(user: @user, action_name: "Teste Log", status: "success")

    get logs_ai_path
    assert_response :success
    assert_match "Teste Log", response.body
  end

  test "should show individual log details" do
    log = AiRequestLog.create!(user: @user, action_name: "Teste Log Detalhado", prompt: "Prompt enviado", status: "success")

    get show_log_ai_path(log)
    assert_response :success
    assert_match "Prompt enviado", response.body
  end

  test "should clear user logs" do
    AiRequestLog.create!(user: @user, action_name: "Teste Log Para Apagar", status: "success")

    assert_difference("AiRequestLog.count", -1) do
      delete clear_logs_ai_path
    end

    assert_redirected_to ai_dashboard_path
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
