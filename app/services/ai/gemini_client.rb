require "net/http"
require "uri"
require "json"

module Ai
  class GeminiClient
    BASE_URL = "https://generativelanguage.googleapis.com/v1beta/models"

    def self.generate_content(prompt, system_instruction: nil, json_response: false)
      api_key = ENV["GEMINI_API_KEY"]
      if api_key.blank?
        raise "GEMINI_API_KEY não configurada no arquivo .env"
      end

      model = ENV.fetch("GEMINI_MODEL", "gemini-2.5-flash")
      url = URI("#{BASE_URL}/#{model}:generateContent?key=#{api_key}")

      payload = {
        contents: [
          {
            parts: [
              { text: prompt }
            ]
          }
        ]
      }

      if system_instruction.present?
        payload[:systemInstruction] = {
          parts: [
            { text: system_instruction }
          ]
        }
      end

      if json_response
        payload[:generationConfig] = {
          responseMimeType: "application/json"
        }
      end

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.open_timeout = 10
      http.read_timeout = 30

      request = Net::HTTP::Post.new(url, { "Content-Type" => "application/json" })
      request.body = payload.to_json

      response = http.request(request)
      body = JSON.parse(response.body) rescue {}

      if response.code.to_i != 200
        error_msg = body.dig("error", "message") || "Erro HTTP #{response.code} na API do Gemini"
        raise "Gemini API Error: #{error_msg}"
      end

      text_result = body.dig("candidates", 0, "content", "parts", 0, "text") || ""
      if json_response
        begin
          JSON.parse(text_result)
        rescue JSON::ParserError
          cleaned = text_result.gsub(/```json\n?|\n?```/, "").strip
          JSON.parse(cleaned)
        end
      else
        text_result
      end
    end
  end
end
