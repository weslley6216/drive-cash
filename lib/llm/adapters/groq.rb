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
        build_connection(BASE_URL) do |f|
          f.request :authorization, 'Bearer', api_key
        end
      end

      def build_payload(messages, tools, system)
        payload = { model: model, messages: [] }
        payload[:messages] << { role: 'system', content: system } if system.present?
        payload[:messages] += messages.map { |m| { role: m[:role], content: m[:content] } }
        payload[:tools] = tools.map { |t| { type: 'function', function: normalize_schema(t) } } if tools.any?
        payload
      end

      def normalize_schema(tool)
        adapted = tool.deep_dup
        adapted.dig(:parameters, :type)&.then { |t| adapted[:parameters][:type] = t.downcase }
        adapted.dig(:parameters, :properties)&.each_value { |p| p[:type] = p[:type].to_s.downcase if p[:type] }
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
          call = message['tool_calls'].first['function']
          input = JSON.parse(call['arguments'])
          input['amount'] = input['amount'].to_f if input.key?('amount')
          Rails.logger.info "[Groq] Tool call: #{call['name']}"
          { type: :tool_use, tool_name: call['name'], tool_input: input }
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
