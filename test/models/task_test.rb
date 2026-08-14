require "test_helper"

class TaskTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "validates recurrence inclusion" do
    task = Task.new(user: @user, title: "Test", recurrence: "invalid")
    assert_not task.valid?
    assert task.errors[:recurrence].any?

    task.recurrence = "daily"
    assert task.valid?
  end

  test "auto generates next task on completion for daily recurrence" do
    initial = Task.create!(user: @user, title: "Relatório Diário", recurrence: "daily", schedule_at: Time.current, status: "pending")

    assert_difference("Task.count", 1) do
      initial.update!(completed: true)
    end

    next_task = Task.where(user: @user, title: "Relatório Diário", completed: nil).last
    assert_not_nil next_task
    assert_equal "daily", next_task.recurrence
    assert_equal (Time.current + 1.day).to_date, next_task.schedule_at.to_date
  end

  test "auto generates next task on completion for weekly recurrence" do
    initial = Task.create!(user: @user, title: "Revisão Semanal", recurrence: "weekly", schedule_at: Time.current, status: "pending")

    assert_difference("Task.count", 1) do
      initial.update!(completed: true)
    end

    next_task = Task.where(user: @user, title: "Revisão Semanal", completed: nil).last
    assert_not_nil next_task
    assert_equal "weekly", next_task.recurrence
    assert_equal (Time.current + 1.week).to_date, next_task.schedule_at.to_date
  end
end
