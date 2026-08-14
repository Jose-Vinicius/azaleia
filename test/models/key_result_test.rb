require "test_helper"

class KeyResultTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @okr = Okr.create!(user: @user, title: "OKR Produto", quarter: "Q3 2026")
  end

  test "valid key result" do
    kr = KeyResult.new(okr: @okr, title: "Entregar MVP da feature X")
    assert kr.valid?
  end

  test "invalid without title" do
    kr = KeyResult.new(okr: @okr)
    assert_not kr.valid?
    assert kr.errors[:title].any?
  end

  test "progress_percentage derived from connected tasks" do
    kr = KeyResult.create!(okr: @okr, title: "Métrica de Redução de Tickets")
    assert_equal 0, kr.progress_percentage

    t1 = @user.tasks.create!(title: "Investigar gargalos", key_result: kr)
    t2 = @user.tasks.create!(title: "Criar automação", key_result: kr)
    t3 = @user.tasks.create!(title: "Validar métricas", key_result: kr)

    assert_equal 0, kr.progress_percentage

    t1.update!(completed: true)
    assert_equal 33, kr.progress_percentage

    t2.update!(completed: true)
    assert_equal 67, kr.progress_percentage

    t3.update!(completed: true)
    assert_equal 100, kr.progress_percentage
  end
end
