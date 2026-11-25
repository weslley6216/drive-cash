class ChatController < ApplicationController
  include ChatSession

  def index
    render Chat::IndexView.new(messages: chat_history)
  end

  def message
    user_text = params[:message].to_s.strip
    return head :bad_request if user_text.blank?

    add_to_history(Chat::Message.from_user(user_text, voice: params[:voice].present?))

    result = Ai::ParserService.new(messages: chat_history, today: Date.current, user: current_user).call
    result = start_preview_queue(result)
    add_to_history(Chat::Message.from_result(result, fallback_content: t('chat.history.preview_sent')))

    respond_with_message(user_text: user_text, result: result)
  end

  def confirm
    return respond_with_duplicate_submit unless consume_preview_nonce(params[:confirm_nonce])

    tool = Ai::Tools::Registry.find(params[:record_action])
    record_params = Chat::Payload.permit(params[:record], tool&.permitted_keys || [])
    persister = Chat::RecordPersister.for(params[:record_action])
    respond_with_confirm_result(persister.persist(record_params, user: current_user), record_params: record_params)
  end

  def cancel_preview
    return respond_with_duplicate_submit unless consume_preview_nonce(params[:confirm_nonce])

    record_preview_cancellation
    respond_with_cancel_result
  end

  def clear
    clear_history
    redirect_to chat_root_path
  end
end
