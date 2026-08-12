require "test_helper"

class GoalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post session_path, params: { email_address: @user.email_address, password: "password" }
    @goal = Goal.create!(user: @user, title: "Meta de Teste", status: :active)
  end

  test "should get index" do
    get goals_path
    assert_response :success
  end

  test "should get new" do
    get new_goal_path
    assert_response :success
  end

  test "should create goal" do
    assert_difference("Goal.count") do
      post goals_path, params: {
        goal: {
          title: "Nova Meta SMART",
          description: "Descrição da meta",
          smart_specific: "Específico",
          status: "active"
        }
      }
    end

    assert_redirected_to goals_path
  end

  test "should show goal" do
    get goal_path(@goal)
    assert_response :success
  end

  test "should get edit" do
    get edit_goal_path(@goal)
    assert_response :success
  end

  test "should update goal" do
    patch goal_path(@goal), params: { goal: { title: "Meta Atualizada" } }
    assert_redirected_to goal_path(@goal)
    assert_equal "Meta Atualizada", @goal.reload.title
  end

  test "should destroy goal" do
    assert_difference("Goal.count", -1) do
      delete goal_path(@goal)
    end

    assert_redirected_to goals_path
  end
end
