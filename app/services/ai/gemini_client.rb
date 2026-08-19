require "net/http"
require "uri"
require "json"

module Ai
  class GeminiClient
    BASE_URL = "https://generativelanguage.googleapis.com/v1beta/models"

    def self.generate_content(prompt, system_instruction: nil, json_response: false, user: nil, action_name: nil)
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

      target_user = user || (defined?(Current) && Current.respond_to?(:user) ? Current.user : nil)
      act_name = action_name.presence || "Requisição IA"

      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      response_text_raw = nil
      status_val = "success"
      error_msg = nil
      prompt_tokens = nil
      completion_tokens = nil
      total_tokens = nil

      begin
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
          status_val = "error"
          raise "Gemini API Error: #{error_msg}"
        end

        usage = body["usageMetadata"] || {}
        prompt_tokens = usage["promptTokenCount"]
        completion_tokens = usage["candidatesTokenCount"]
        total_tokens = usage["totalTokenCount"]

        text_result = body.dig("candidates", 0, "content", "parts", 0, "text") || ""
        response_text_raw = text_result

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
      rescue StandardError => e
        status_val = "error"
        error_msg ||= e.message
        raise e
      ensure
        end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        duration = ((end_time - start_time) * 1000).round

        if target_user
          begin
            target_user.ai_request_logs.create!(
              action_name: act_name,
              ai_model: model,
              prompt: prompt,
              system_instruction: system_instruction,
              response_body: response_text_raw.is_a?(String) ? response_text_raw : response_text_raw.to_json,
              status: status_val,
              error_message: error_msg,
              duration_ms: duration,
              prompt_tokens: prompt_tokens,
              completion_tokens: completion_tokens,
              total_tokens: total_tokens
            )
          rescue StandardError => log_err
            Rails.logger.error("Erro ao salvar log de IA: #{log_err.message}")
          end
        end
      end
    end
  end
end
