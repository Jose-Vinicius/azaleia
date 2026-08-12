require "test_helper"

class GoalTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "valid goal" do
    goal = Goal.new(
      user: @user,
      title: "Melhorar Testes de Realidade",
      description: "Foco no alinhamento com a realidade",
      smart_specific: "Acompanhar métricas diariamente",
      status: :active
    )
    assert goal.valid?
  end

  test "invalid without title" do
    goal = Goal.new(user: @user)
    assert_not goal.valid?
    assert goal.errors[:title].any?
  end

  test "enum status mapping" do
    goal = Goal.new(user: @user, title: "Meta SMART", status: :active)
    assert goal.active?
    goal.status = :completed
    assert goal.completed?
    assert_equal 3, Goal.statuses[goal.status]
  end
end
