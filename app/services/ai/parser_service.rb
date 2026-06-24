module Ai
  class ParserService
    TOOLS = Ai::Tools::Registry.declarations

    PROMPT_PATH = Rails.root.join('app', 'services', 'ai', 'prompts', 'financial_assistant.txt').freeze

    def initialize(messages:, today: Date.current, client: Llm::Client, user: nil)
      @messages = messages
      @today = today
      @client = client
      @user = user
    end

    def call
      Rails.logger.debug "[ParserService] Starting processing for #{@messages.size} message(s)"

      response = @client.chat(
        messages: @messages,
        tools:    TOOLS,
        system:   system_prompt
      )

      process_response(response)
    rescue Llm::RateLimitError => e
      Rails.logger.warn "[ParserService] Rate Limit Hit: #{e.message}"
      { type: :text, content: I18n.t('chat.errors.rate_limit') }
    rescue Llm::ConfigurationError => e
      Rails.logger.error "[ParserService] Misconfiguration: #{e.message}"
      { type: :text, content: I18n.t('chat.errors.misconfig') }
    rescue Llm::Error => e
      Rails.logger.error "[ParserService] API Error: #{e.message}"
      { type: :text, content: I18n.t('chat.errors.api_error') }
    rescue StandardError => e
      Rails.logger.error "[ParserService] UNEXPECTED SYSTEM ERROR: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.first(5).join("\n")
      { type: :text, content: I18n.t('chat.errors.unexpected') }
    end

    private

    def process_response(response)
      case response[:type]
      when :tool_use then dispatch_tool(response)
      when :text then { type: :text, content: response[:content].presence || I18n.t('chat.message.not_understood') }
      else
        Rails.logger.warn "[ParserService] Unexpected response type: #{response.inspect}"
        { type: :text, content: I18n.t('chat.message.not_understood') }
      end
    end

    def dispatch_tool(response)
      tool = Ai::Tools::Registry.find(response[:tool_name])
      return { type: :text, content: I18n.t('chat.message.fallback') } unless tool

      if tool.query?
        build_answer(tool, response[:tool_input])
      else
        build_preview(tool, response[:tool_input], extra_calls: response[:extra_calls])
      end
    end

    def build_answer(tool, tool_input)
      params = parse_params(tool_input)
      data = tool.reader.new(params, user: @user).call
      content = tool.answer_presenter.new(data).call
      { type: :answer, content: content }
    rescue StandardError => e
      Rails.logger.error "[ParserService] Reader error for #{tool.name}: #{e.message}"
      { type: :text, content: I18n.t('chat.errors.api_error') }
    end

    def build_preview(tool, tool_input, extra_calls: nil)
      params = parse_params(tool_input)
      return missing_amount_result(tool.name, params) if invalid_amount?(tool, params)

      result = preview_for(tool, params)
      result[:extra_calls] = extra_calls if extra_calls.present?
      result
    rescue JSON::ParserError
      { type: :text, content: I18n.t('chat.message.fallback') }
    end

    def parse_params(tool_input)
      tool_input.is_a?(String) ? JSON.parse(tool_input) : tool_input
    end

    def invalid_amount?(tool, params)
      return false unless tool.requires_amount

      params['amount'].to_f <= 0
    end

    def missing_amount_result(tool_name, params)
      Rails.logger.warn "[ParserService] Rejected #{tool_name} with invalid amount: #{params['amount']}"
      { type: :text, content: I18n.t('chat.errors.missing_amount') }
    end

    def preview_for(tool, params)
      {
        type:    :preview,
        action:  tool.name,
        params:  params,
        summary: tool.summary_presenter.new(params).call,
        content: I18n.t('chat.history.preview_sent')
      }
    end

    def system_prompt
      today_str = "#{@today.strftime('%d/%m/%Y')} (#{@today.strftime('%Y-%m-%d')})"
      File.read(PROMPT_PATH).gsub('%{today}', today_str)
    end
  end
end
