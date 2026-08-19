require "test_helper"

class Ai::OpenTasksSchedulerServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    ENV["GEMINI_API_KEY"] = "fake_test_key"
  end

  test "suggest returns message when no open tasks exist" do
    @user.tasks.destroy_all
    result = Ai::OpenTasksSchedulerService.suggest(@user)

    assert_equal [], result["suggestions"]
    assert_match "Nenhuma tarefa em aberto", result["summary"]
  end

  test "apply_schedules updates selected tasks schedule_at" do
    task1 = Task.create!(user: @user, title: "Tarefa 1", status: "pending")
    task2 = Task.create!(user: @user, title: "Tarefa 2", status: "pending")

    schedule_params = {
      task1.id.to_s => { "selected" => "1", "schedule_at" => "2026-08-25T10:00" },
      task2.id.to_s => { "selected" => "0", "schedule_at" => "2026-08-26T14:00" }
    }

    count = Ai::OpenTasksSchedulerService.apply_schedules(@user, schedule_params)
    assert_equal 1, count
    assert_equal Time.zone.parse("2026-08-25T10:00"), task1.reload.schedule_at
    assert_nil task2.reload.schedule_at
  end
end
