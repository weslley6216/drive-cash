module Llm
  module Adapters
    class Gemini < BaseAdapter
      BASE_URL = 'https://generativelanguage.googleapis.com'.freeze

      def chat(messages:, tools: [], system: nil)
        api_key = ENV.fetch('GEMINI_API_KEY') { raise Llm::ConfigurationError, 'GEMINI_API_KEY is not set.' }
        model = ENV.fetch('GEMINI_MODEL', 'gemini-2.0-flash')
        endpoint = "/v1beta/models/#{model}:generateContent?key=#{api_key}"

        Rails.logger.info "[Gemini] Requesting #{model}"
        response = connection.post(endpoint, build_payload(messages, tools, system))

        handle_error!(response) if response.status != 200 || response.body['error']

        normalize(response.body)
      end

      private

      def connection
        build_connection(BASE_URL)
      end

      def build_payload(messages, tools, system)
        payload = {}
        payload[:systemInstruction] = { parts: [{ text: system }] } if system.present?
        payload[:contents] = messages.map { |msg| { role: normalize_role(msg[:role]), parts: [{ text: msg[:content].to_s }] } }
        payload[:tools] = [{ functionDeclarations: tools }] if tools.any?
        payload
      end

      def normalize_role(role)
        role.to_s == 'assistant' ? 'model' : 'user'
      end

      def handle_error!(response)
        body = response.body || {}
        error_msg = body.dig('error', 'message') || "HTTP #{response.status}"

        if RATE_LIMIT_STATUSES.include?(response.status) || error_msg.match?(/high demand/i)
          raise Llm::RateLimitError, error_msg
        else
          raise Llm::Error, error_msg
        end
      end

      def normalize(body)
        candidate = body.dig('candidates', 0)
        return { type: :text, content: '' } unless candidate

        parts = candidate.dig('content', 'parts') || []
        function_parts = parts.select { |part| part['functionCall'] }

        if function_parts.any?
          calls = function_parts.map do |part|
            call = part['functionCall']
            { name: call['name'], input: call['args'] || {} }
          end

          first = calls.first
          Rails.logger.info "[Gemini] Tool call: #{first[:name]} (#{calls.size} total)"

          text_parts = parts.reject { |part| part['functionCall'] }
          text_before = text_parts.map { |part| part['text'].to_s }.join.strip.presence

          result = { type: :tool_use, tool_name: first[:name], tool_input: first[:input] }
          result[:extra_calls] = calls.drop(1) if calls.size > 1
          result[:text_before] = text_before
          result
        else
          part = parts.first
          return { type: :text, content: '' } unless part

          content = part['text'].to_s.strip
          content = sanitize_function_leaks(content)
          { type: :text, content: content }
        end
      end
    end
  end
end
