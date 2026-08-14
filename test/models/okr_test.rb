require "test_helper"

class OkrTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "valid okr" do
    okr = Okr.new(
      user: @user,
      title: "OKR Suporte",
      description: "Consolidar a ponte Suporte -> Produto",
      quarter: "Q3 2026",
      status: :active
    )
    assert okr.valid?
  end

  test "invalid without title or quarter" do
    okr = Okr.new(user: @user, quarter: nil)
    assert_not okr.valid?
    assert okr.errors[:title].any?
    assert okr.errors[:quarter].any?
  end

  test "progress_percentage calculates average of key_results" do
    okr = Okr.create!(user: @user, title: "OKR Suporte", quarter: "Q3 2026")
    assert_equal 0, okr.progress_percentage

    kr1 = okr.key_results.create!(title: "Relatório quinzenal")
    kr2 = okr.key_results.create!(title: "Bugs recorrentes")

    # Initially 0 tasks in both KRs
    assert_equal 0, okr.progress_percentage

    # Add 2 tasks to kr1: 1 completed, 1 pending (50%)
    @user.tasks.create!(title: "Task 1", key_result: kr1, completed: true)
    @user.tasks.create!(title: "Task 2", key_result: kr1, completed: false)

    # Add 1 task to kr2: 1 completed (100%)
    @user.tasks.create!(title: "Task 3", key_result: kr2, completed: true)

    # kr1 = 50%, kr2 = 100% -> okr average = 75%
    assert_equal 75, okr.progress_percentage
  end
end
