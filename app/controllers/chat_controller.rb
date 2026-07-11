class ChatController < ApplicationController
  include ChatSession

  def index
    render Chat::IndexView.new(messages: chat_history)
  end

  def message
    user_text = params[:message].to_s.strip
    return head :bad_request if user_text.blank?

    reset_continuation_depth
    add_to_history(Chat::Message.from_user(user_text))

    result = Ai::ParserService.new(messages: chat_history, today: Date.current, user: current_user).call
    result = attach_nonce_if_preview(result)
    add_to_history(Chat::Message.from_result(result, fallback_content: t('chat.history.preview_sent')))

    respond_with_message(user_text: user_text, result: result)
  end

  def confirm
    return respond_with_duplicate_submit unless consume_confirm_nonce(params[:confirm_nonce])

    record_params = params[:record]&.to_unsafe_h || {}
    persister = Chat::RecordPersister.for(params[:record_action])
    respond_with_confirm_result(persister.persist(record_params, user: current_user), record_params: record_params)
  end

  def cancel_preview
    add_to_history(Chat::Message.from_result(
      { type: :text, content: t('chat.history.preview_cancelled') },
      fallback_content: t('chat.history.preview_cancelled')
    ))

    respond_with_cancel_continuation
  end

  def clear
    clear_history
    redirect_to chat_root_path
  end
end
