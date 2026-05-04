class ChatController < ApplicationController
  include ChatSession

  CONFIRM_I18N_KEYS = {
    'create_earning' => 'chat.confirm.success_earning',
    'create_expense' => 'chat.confirm.success_expense'
  }.freeze

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
    persister = Chat::RecordPersister.for(params[:record_action])
    return head(:bad_request) unless persister

    result = persister.persist(params[:record] || {})

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
    i18n_key = CONFIRM_I18N_KEYS[action]

    add_to_history(Chat::Message.from_result(
      { type: :text, content: t(i18n_key) },
      fallback_content: t(i18n_key)
    ))

    render Chat::ConfirmView.new(
      success: true,
      message: t(i18n_key),
      action: action,
      date: record.date
    )
  end
end
