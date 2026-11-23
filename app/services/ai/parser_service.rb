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
    rescue Llm::QuotaExhaustedError => e
      Rails.logger.warn "[ParserService] Daily quota exhausted: #{e.message}"
      { type: :text, content: I18n.t('chat.errors.quota_exhausted') }
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
        Rails.logger.warn "[ParserService] Unexpected response type: #{response[:type].inspect}"
        { type: :text, content: I18n.t('chat.message.not_understood') }
      end
    end

    def dispatch_tool(response)
      calls = [{ name: response[:tool_name], input: response[:tool_input] }, *Array(response[:extra_calls])]
      tool = Ai::Tools::Registry.find(calls.first[:name])
      return { type: :text, content: I18n.t('chat.message.fallback') } unless tool

      if tool.query?
        warn_ignored_extras(calls.drop(1))
        dispatch_query(calls.first[:input])
      else
        build_batch_preview(calls, text_before: response[:text_before])
      end
    end

    def warn_ignored_extras(calls)
      return if calls.empty?

      Rails.logger.warn "[ParserService] Ignoring #{calls.size} extra tool_call(s) after a query: #{calls.map { |call| call[:name] }.inspect}"
    end

    def dispatch_query(tool_input)
      params = parse_params(tool_input)
      query_kind = Ai::Tools::Registry.query_kind(params['type'])
      return { type: :text, content: I18n.t('chat.message.fallback') } unless query_kind

      build_answer(query_kind.reader, query_kind.answer_presenter, params)
    end

    def build_answer(reader_class, presenter_class, params)
      data = reader_class.new(params, user: @user).call
      content = presenter_class.new(data).call
      { type: :answer, content: content }
    rescue StandardError => e
      Rails.logger.error "[ParserService] Reader error: #{e.message}"
      { type: :text, content: I18n.t('chat.errors.api_error') }
    end

    def build_batch_preview(calls, text_before:)
      previews = calls.filter_map { |call| preview_for_call(call) }
      return { type: :text, content: I18n.t('chat.errors.missing_amount') } if previews.empty?

      previews.first[:text_before] = text_before if text_before.present?
      previews.first[:queued] = previews.drop(1) if previews.size > 1
      previews.first
    rescue JSON::ParserError
      { type: :text, content: I18n.t('chat.message.fallback') }
    end

    def preview_for_call(call)
      tool = Ai::Tools::Registry.find(call[:name])
      return discard_call(call[:name]) if tool.nil? || tool.query?

      params = parse_params(call[:input])
      return discard_invalid_amount(tool.name) if invalid_amount?(tool, params)

      preview_for(tool, params)
    end

    def discard_call(name)
      Rails.logger.warn "[ParserService] Discarding #{name} from a multi-create batch"
      nil
    end

    def parse_params(tool_input)
      tool_input.is_a?(String) ? JSON.parse(tool_input) : tool_input
    end

    def invalid_amount?(tool, params)
      return false unless tool.requires_amount

      params['amount'].to_f <= 0
    end

    def discard_invalid_amount(tool_name)
      Rails.logger.warn "[ParserService] Rejected #{tool_name} with invalid amount"
      nil
    end

    def preview_for(tool, params)
      summary = tool.summary_presenter.new(params).call
      {
        type:    :preview,
        action:  tool.name,
        params:  params,
        summary: summary,
        content: I18n.t('chat.history.preview_sent_detail', summary: summary)
      }
    end

    def system_prompt
      today_str = "#{@today.strftime('%d/%m/%Y')} (#{@today.strftime('%Y-%m-%d')})"
      File.read(PROMPT_PATH).gsub('%{today}', today_str)
    end
  end
end
