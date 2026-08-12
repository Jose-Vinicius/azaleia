require "test_helper"

class TaskAnalysisServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    ENV["GEMINI_API_KEY"] = "fake_test_key"
  end

  test "calls GeminiClient with aggregated task and psychometric data" do
    mock_response = "### 📊 Visão Geral da Produtividade\nBom desempenho."

    stub_gemini(mock_response) do
      result = Ai::TaskAnalysisService.call(@user, period_days: 30)
      assert_includes result, "Visão Geral da Produtividade"
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
