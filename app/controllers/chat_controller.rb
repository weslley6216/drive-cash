class ChatController < ApplicationController
  include ChatSession
  include ChatRecordBuilder

  def index
    render Chat::IndexView.new(messages: chat_history)
  end

  def message
    user_text = params[:message].to_s.strip
    return head :bad_request if user_text.blank?

    add_to_history(Chat::Message.from_user(user_text))

    result = Ai::ParserService.new(messages: chat_history, today: Date.current).call

    add_to_history(Chat::Message.from_result(result, fallback_content: t('chat.history.preview_sent')))

    respond_to do |format|
      format.turbo_stream do
        render Chat::MessageView.new(user_text: user_text, result: result)
      end
    end
  end

  def confirm
    record = build_record(params[:record_action], params[:record] || {})
    return head :bad_request unless record

    respond_to do |format|
      format.turbo_stream do
        if record.save
          i18n_key = CONFIRM_I18N_KEYS[params[:record_action]]

          add_to_history(Chat::Message.from_result(
            { type: :text, content: t(i18n_key) },
            fallback_content: t(i18n_key)
          ))

          render Chat::ConfirmView.new(
            success: true,
            message: t(i18n_key),
            action: params[:record_action],
            date: record.date
          )
        else
          render Chat::ConfirmView.new(
            success: false,
            message: "#{t('chat.confirm.error_prefix')} #{record.errors.full_messages.join(', ')}"
          )
        end
      end
    end
  end

  def clear
    clear_history
    redirect_to chat_root_path
  end
end
