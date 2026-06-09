module Ai
  class ParserService
    TOOLS = [
      Ai::Tools::CreateEarning.declaration,
      Ai::Tools::CreateExpense.declaration
    ].freeze

    PROMPT_PATH = Rails.root.join('app', 'services', 'ai', 'prompts', 'financial_assistant.txt').freeze

    def initialize(messages:, today: Date.current)
      @messages = messages
      @today    = today
    end

    def call
      Rails.logger.debug "[ParserService] Starting processing for #{@messages.size} message(s)"

      response = Llm::Client.chat(
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
      when :tool_use then build_preview(response[:tool_name], response[:tool_input])
      when :text     then { type: :text, content: response[:content].presence || I18n.t('chat.message.not_understood') }
      else
        Rails.logger.warn "[ParserService] Unexpected response type: #{response.inspect}"
        { type: :text, content: I18n.t('chat.message.not_understood') }
      end
    end

    def build_preview(tool_name, tool_input)
      params = tool_input.is_a?(String) ? JSON.parse(tool_input) : tool_input

      if %w[create_expense create_earning].include?(tool_name)
        amount = params['amount'].to_f
        if amount <= 0
          Rails.logger.warn "[ParserService] Rejected #{tool_name} with invalid amount: #{params['amount']}"
          return { type: :text, content: I18n.t('chat.errors.missing_amount') }
        end
      end

      summary = Chat::SummaryPresenter.build(tool_name, params)
      content = I18n.t('chat.history.preview_sent')

      { type: :preview, action: tool_name, params: params, summary: summary, content: content }
    rescue JSON::ParserError
      { type: :text, content: I18n.t('chat.message.fallback') }
    end

    def system_prompt
      today_str = "#{@today.strftime('%d/%m/%Y')} (#{@today.strftime('%Y-%m-%d')})"
      File.read(PROMPT_PATH).gsub('%{today}', today_str)
    end
  end
end
