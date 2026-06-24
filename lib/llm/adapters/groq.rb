module Llm
  module Adapters
    class Groq < BaseAdapter
      BASE_URL = 'https://api.groq.com/openai/v1'.freeze

      def chat(messages:, tools: [], system: nil)
        api_key = ENV.fetch('GROQ_API_KEY') { raise Llm::ConfigurationError, 'GROQ_API_KEY is not set.' }
        Rails.logger.info "[Groq] Requesting #{model}"

        payload = build_payload(messages, tools, system)
        response = connection(api_key).post('chat/completions', payload)

        handle_error!(response) if response.status != 200

        normalize(response.body)
      end

      private

      def model
        ENV.fetch('GROQ_MODEL', 'llama-3.3-70b-versatile')
      end

      def connection(api_key)
        build_connection(BASE_URL) do |conn|
          conn.request :authorization, 'Bearer', api_key
        end
      end

      def build_payload(messages, tools, system)
        payload = { model: model, messages: [] }
        payload[:messages] << { role: 'system', content: system } if system.present?
        payload[:messages] += messages.map { |message| { role: message[:role], content: message[:content] } }
        payload[:tools] = tools.map { |tool| { type: 'function', function: normalize_schema(tool) } } if tools.any?
        payload
      end

      def normalize_schema(tool)
        adapted = tool.deep_dup
        adapted.dig(:parameters, :type)&.then { |type| adapted[:parameters][:type] = type.downcase }
        adapted.dig(:parameters, :properties)&.each_value { |property| property[:type] = property[:type].to_s.downcase if property[:type] }
        adapted
      end

      def handle_error!(response)
        error_msg = response.body.dig('error', 'message') || "HTTP #{response.status}"

        if RATE_LIMIT_STATUSES.include?(response.status)
          raise Llm::RateLimitError, error_msg
        else
          raise Llm::Error, error_msg
        end
      end

      def normalize(body)
        message = body.dig('choices', 0, 'message')
        return { type: :text, content: '' } unless message

        if message['tool_calls']
          calls = message['tool_calls'].map do |tc|
            { name: tc.dig('function', 'name'), input: JSON.parse(tc.dig('function', 'arguments')) }
          end

          first = calls.first
          Rails.logger.info "[Groq] Tool call: #{first[:name]} (#{calls.size} total)"

          result = { type: :tool_use, tool_name: first[:name], tool_input: first[:input] }
          result[:extra_calls] = calls.drop(1) if calls.size > 1
          result[:text_before] = message['content'].to_s.strip.presence
          result
        else
          content = message['content'].to_s.strip
          content = sanitize_function_leaks(content)
          { type: :text, content: content }
        end
      rescue JSON::ParserError
        { type: :text, content: '' }
      end
    end
  end
end
