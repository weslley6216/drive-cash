class ChatController < ApplicationController
  include ChatSession

  def index
    render Chat::IndexView.new(messages: chat_history)
  end

  def message
    user_text = params[:message].to_s.strip
    return head :bad_request if user_text.blank?

    add_to_history(Chat::Message.from_user(user_text))

    result = Ai::ParserService.new(messages: chat_history, today: Date.current, user: current_user).call

    if result[:extra_calls].present?
      push_pending_calls(result[:extra_calls])
      result = result.except(:extra_calls)
    end

    add_to_history(Chat::Message.from_result(result, fallback_content: t('chat.history.preview_sent')))

    respond_to do |format|
      format.turbo_stream do
        render Chat::MessageView.new(user_text: user_text, result: result)
      end
    end
  end

  def confirm
    persister = Chat::RecordPersister.for(params[:record_action])
    record = params[:record] || {}
    payload = record.respond_to?(:to_unsafe_h) ? record.to_unsafe_h : record.to_h
    result = persister.persist(payload, user: current_user)

    respond_to do |format|
      format.turbo_stream do
        if result.success?
          finalize_chat_confirm_success(action: result.action, record: result.record)
        else
          render Chat::ConfirmView.new(
            success: false,
            message: "#{t('chat.confirm.error_prefix')} #{result.errors.join(', ')}"
          )
        end
      end
    end
  end

  def clear
    clear_history
    redirect_to chat_root_path
  end

  private

  def finalize_chat_confirm_success(action:, record:)
    i18n_key = Ai::Tools::Registry.find(action).confirm_key

    add_to_history(Chat::Message.from_result(
      { type: :text, content: t(i18n_key) },
      fallback_content: t(i18n_key)
    ))

    next_call = pop_pending_call

    if next_call
      dispatch_next_preview(next_call)
    else
      render Chat::ConfirmView.new(
        success: true,
        message: t(i18n_key),
        action:  action,
        date:    record.respond_to?(:date) ? record.date : nil
      )
    end
  end

  def dispatch_next_preview(call)
    tool = Ai::Tools::Registry.find(call[:name])
    unless tool
      render Chat::ConfirmView.new(success: false, message: t('chat.errors.unknown_action'))
      return
    end

    params_hash = call[:input].is_a?(Hash) ? call[:input] : {}
    summary = tool.summary_presenter.new(params_hash).call
    result = { type: :preview, action: call[:name], params: params_hash, summary: summary, content: t('chat.history.preview_sent') }

    add_to_history(Chat::Message.from_result(result, fallback_content: t('chat.history.preview_sent')))

    render Chat::MessageView.new(user_text: nil, result: result)
  end
end
