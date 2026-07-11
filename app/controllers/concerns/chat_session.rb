module ChatSession
  extend ActiveSupport::Concern

  private

  HISTORY_LIMIT = 12
  MAX_CONTINUATION_DEPTH = 5
  private_constant :HISTORY_LIMIT

  def chat_history
    (session[:chat_history] || []).map(&:symbolize_keys)
  end

  def add_to_history(message)
    history = chat_history
    history << message.to_session_hash
    session[:chat_history] = history.last(HISTORY_LIMIT)
  end

  def clear_history
    session.delete(:chat_history)
    session.delete(:continuation_depth)
    session.delete(:confirm_nonce)
    session.delete(:confirmed_signatures)
  end

  def continuation_depth
    session[:continuation_depth].to_i
  end

  def increment_continuation_depth
    session[:continuation_depth] = continuation_depth + 1
  end

  def reset_continuation_depth
    session.delete(:continuation_depth)
  end

  def continuation_depth_exceeded?
    continuation_depth >= MAX_CONTINUATION_DEPTH
  end

  def set_confirm_nonce(nonce)
    session[:confirm_nonce] = nonce
  end

  def consume_confirm_nonce(provided_nonce)
    stored = session[:confirm_nonce]
    return true if stored.blank? && provided_nonce.blank?
    return false if stored.blank? || provided_nonce.blank?
    return false unless ActiveSupport::SecurityUtils.secure_compare(stored, provided_nonce)
    session.delete(:confirm_nonce)
    true
  end

  def attach_nonce_if_preview(result)
    return result unless result[:type] == :preview
    nonce = SecureRandom.hex(16)
    set_confirm_nonce(nonce)
    result.merge(nonce: nonce)
  end

  def respond_with_message(user_text:, result:)
    respond_to do |format|
      format.turbo_stream { render Chat::MessageView.new(user_text: user_text, result: result) }
    end
  end

  def respond_with_duplicate_submit
    respond_to do |format|
      format.turbo_stream do
        render Chat::ConfirmView.new(success: false, message: t('chat.confirm.duplicate_submit'))
      end
    end
  end

  def respond_with_confirm_result(result, record_params: {})
    respond_to do |format|
      format.turbo_stream do
        if result.success?
          finalize_chat_confirm_success(action: result.action, record: result.record, record_params: record_params)
        else
          render Chat::ConfirmView.new(
            success: false,
            message: "#{t('chat.confirm.error_prefix')} #{result.errors.join(', ')}"
          )
        end
      end
    end
  end

  def respond_with_cancel_continuation
    respond_to do |format|
      format.turbo_stream { auto_continue_and_render_cancel }
    end
  end

  def finalize_chat_confirm_success(action:, record:, record_params:)
    i18n_key = Ai::Tools::Registry.find(action).confirm_key
    record_confirmed_signature(action: action, params: record_params)

    add_to_history(Chat::Message.from_result(
      { type: :text, content: t('chat.history.record_confirmed', summary: confirm_summary(action, record_params)) },
      fallback_content: t(i18n_key)
    ))

    auto_continue_and_render_confirm(action: action, record: record, i18n_key: i18n_key)
  end

  def confirm_summary(action, record_params)
    Ai::Tools::Registry.find(action).summary_presenter.new(record_params).call
  end

  def last_preview_summary
    chat_history.reverse_each.find { |message| message[:summary].present? }&.dig(:summary)
  end

  def record_confirmed_signature(action:, params:)
    signatures = session[:confirmed_signatures] || []
    signatures << Chat::PreviewSignature.from(action: action, params: params).to_session_hash
    session[:confirmed_signatures] = signatures
  end

  def confirmed_signatures
    (session[:confirmed_signatures] || []).map do |entry|
      Chat::PreviewSignature.from(action: entry['action'], params: entry['params'])
    end
  end

  def reset_confirmed_signatures
    session.delete(:confirmed_signatures)
  end

  def dedup_continuation(continuation)
    return continuation unless continuation[:type] == :preview

    candidate = Chat::PreviewSignature.from(action: continuation[:action], params: continuation[:params])
    return continuation unless confirmed_signatures.any? { |signature| signature.matches?(candidate) }

    { type: :text, content: t('chat.history.all_registered') }
  end

  def auto_continue_and_render_confirm(action:, record:, i18n_key:)
    if continuation_depth_exceeded?
      render Chat::ConfirmView.new(
        success: true,
        message: t(i18n_key),
        action:  action,
        date:    record.respond_to?(:date) ? record.date : nil
      )
      return
    end

    increment_continuation_depth
    continuation = Ai::ParserService.new(messages: chat_history, today: Date.current, user: current_user).call
    continuation = dedup_continuation(continuation)
    continuation = attach_nonce_if_preview(continuation)

    fallback = continuation[:type] == :preview ? t('chat.history.preview_sent') : continuation[:content].to_s
    add_to_history(Chat::Message.from_result(continuation, fallback_content: fallback)) if continuation[:type].in?(%i[text preview])

    render Chat::ConfirmView.new(
      success:      true,
      message:      t(i18n_key),
      action:       action,
      date:         record.respond_to?(:date) ? record.date : nil,
      continuation: continuation[:type].in?(%i[text preview]) ? continuation : nil
    )
  end

  def auto_continue_and_render_cancel
    if continuation_depth_exceeded?
      render Chat::MessageView.new(
        user_text: nil,
        result:    { type: :text, content: t('chat.history.preview_cancelled') }
      )
      return
    end

    increment_continuation_depth
    continuation = Ai::ParserService.new(messages: chat_history, today: Date.current, user: current_user).call
    continuation = dedup_continuation(continuation)
    continuation = attach_nonce_if_preview(continuation)

    if continuation[:type] == :preview
      add_to_history(Chat::Message.from_result(continuation, fallback_content: t('chat.history.preview_sent')))
    end

    render Chat::MessageView.new(user_text: nil, result: continuation)
  end
end
