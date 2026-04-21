module Llm
  module Adapters
    class Gemini < BaseAdapter
      BASE_URL = 'https://generativelanguage.googleapis.com'.freeze

      def chat(messages:, tools: [], system: nil)
        api_key  = ENV.fetch('GEMINI_API_KEY') { raise Llm::ConfigurationError, 'GEMINI_API_KEY is not set.' }
        model    = ENV.fetch('GEMINI_MODEL', 'gemini-2.0-flash')
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
        body      = response.body || {}
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

        part = candidate.dig('content', 'parts', 0)
        return { type: :text, content: '' } unless part

        if part['functionCall']
          call = part['functionCall']
          Rails.logger.info "[Gemini] Tool call: #{call['name']}"
          { type: :tool_use, tool_name: call['name'], tool_input: call['args'] }
        else
          { type: :text, content: part['text'].to_s.strip }
        end
      end
    end
  end
end
