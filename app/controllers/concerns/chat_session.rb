module ChatSession
  extend ActiveSupport::Concern

  private

  HISTORY_LIMIT = 12
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
    session.delete(:confirm_nonce)
    session.delete(:preview_queue)
  end

  def set_confirm_nonce(nonce)
    session[:confirm_nonce] = nonce
  end

  def consume_preview_nonce(provided_nonce)
    stored = session[:confirm_nonce]
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

  def preview_queue
    Chat::PreviewQueue.from_session(session[:preview_queue])
  end

  def start_preview_queue(result)
    store_preview_queue(Chat::PreviewQueue.from_result(result))
    session.delete(:confirm_nonce)
    attach_nonce_if_preview(result)
  end

  def advance_preview_queue
    queue = preview_queue.advance
    store_preview_queue(queue)

    next_result = next_queue_result(queue)
    add_to_history(Chat::Message.from_result(next_result, fallback_content: t('chat.history.preview_sent'))) if next_result
    next_result
  end

  def store_preview_queue(queue)
    queue.empty? ? session.delete(:preview_queue) : session[:preview_queue] = queue.to_session_hash
  end

  def next_queue_result(queue)
    return attach_nonce_if_preview(queue.head) if queue.head
    return { type: :text, content: t('chat.history.queue_finished').sample } if queue.batch?

    nil
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

  def respond_with_confirm_result(result, record_params:)
    respond_to do |format|
      format.turbo_stream do
        if result.success?
          finalize_chat_confirm_success(action: result.action, record: result.record, record_params: record_params)
        else
          render Chat::ConfirmView.new(
            success:      false,
            message:      "#{t('chat.confirm.error_prefix')} #{result.errors.join(', ')}",
            continuation: advance_preview_queue
          )
        end
      end
    end
  end

  def finalize_chat_confirm_success(action:, record:, record_params:)
    i18n_key = Ai::Tools::Registry.find(action).confirm_key

    add_to_history(Chat::Message.from_result(
      { type: :text, content: t('chat.history.record_confirmed', summary: confirm_summary(action, record_params)) },
      fallback_content: t(i18n_key)
    ))

    render Chat::ConfirmView.new(
      success:      true,
      message:      t(i18n_key),
      action:       action,
      date:         record.respond_to?(:date) ? record.date : nil,
      continuation: advance_preview_queue
    )
  end

  def confirm_summary(action, record_params)
    Ai::Tools::Registry.find(action).summary_presenter.new(record_params).call
  end

  def record_preview_cancellation
    summary = preview_queue.head&.dig(:summary)
    content = summary.present? ? t('chat.history.record_cancelled', summary: summary) : t('chat.history.preview_cancelled')

    add_to_history(Chat::Message.from_result(
      { type: :text, content: content },
      fallback_content: t('chat.history.preview_cancelled')
    ))
  end

  def respond_with_cancel_result
    respond_to do |format|
      format.turbo_stream do
        render Chat::MessageView.new(
          user_text: nil,
          result:    advance_preview_queue || { type: :text, content: t('chat.history.preview_cancelled') }
        )
      end
    end
  end
end
