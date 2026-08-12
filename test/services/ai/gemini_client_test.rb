require "test_helper"

class GeminiClientTest < ActiveSupport::TestCase
  test "raises error when GEMINI_API_KEY is not configured" do
    old_key = ENV["GEMINI_API_KEY"]
    ENV["GEMINI_API_KEY"] = nil

    assert_raises(RuntimeError) do
      Ai::GeminiClient.generate_content("Olá")
    end
  ensure
    ENV["GEMINI_API_KEY"] = old_key
  end
end
