require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @task = tasks(:one)
    @user = users(:one)
    post session_url, params: { email_address: @user.email_address, password: "password" }
  end

  test "should get new" do
    get new_task_url
    assert_response :success
  end

  test "should create task" do
    assert_difference("Task.count") do
      post tasks_url, params: { task: { description: @task.description, schedule_at: @task.schedule_at, title: @task.title, estimated_minutes: 0, multiplier_id: multipliers(:one).id } }
    end

    assert_redirected_to dashboard_index_path
  end

  test "should show task" do
    get task_url(@task)
    assert_response :success
  end

  test "should get edit" do
    get edit_task_url(@task)
    assert_response :success
  end

  test "should update task" do
    patch task_url(@task), params: { task: { description: @task.description, schedule_at: @task.schedule_at, title: @task.title } }
    assert_redirected_to dashboard_index_path
  end

  test "should destroy task" do
    assert_difference("Task.count", -1) do
      delete task_url(@task)
    end

    assert_redirected_to dashboard_index_path
  end
end
