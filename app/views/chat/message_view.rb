module Chat
  class MessageView < ApplicationView
    include Formatting

    def initialize(user_text:, result:)
      @user_text = user_text
      @result    = result
    end

    def view_template
      raw turbo_stream.append('chat_messages') { ai_response }
    end

    private

    def ai_response
      case @result[:type]
      when :text    then text_bubble(@result[:content])
      when :preview then preview_card
      else
        text_bubble(t('chat.errors.unexpected'))
      end
    end

    def text_bubble(text)
      div(class: 'flex items-start gap-2') do
        sparkles_icon
        div(class: 'bg-white border border-slate-200 px-4 py-2.5 rounded-2xl rounded-tl-sm max-w-[80%] text-sm text-slate-700 shadow-sm leading-relaxed') do
          plain text
        end
      end
    end

    def sparkles_icon
      div(class: 'w-7 h-7 bg-violet-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5') do
        render PhlexIcons::Lucide::Sparkles.new(class: 'w-4 h-4 text-violet-600')
      end
    end

    def preview_card
      div(class: 'flex items-start gap-2') do
        sparkles_icon
        div(class: 'bg-white border-2 border-violet-200 rounded-2xl rounded-tl-sm max-w-[80%] shadow-sm overflow-hidden') do
          div(class: 'px-4 py-3 bg-violet-50') do
            p(class: 'text-xs font-medium text-violet-700 mb-1') { t('chat.message.understood') }
            p(class: 'text-sm font-semibold text-slate-800') { @result[:summary] || t('chat.message.fallback') }
          end

          div(class: 'px-4 py-3 flex gap-2', data: { chat_target: 'cardActions' }) do
            confirm_form
            cancel_button
          end
        end
      end
    end

    def confirm_form
      action  = @result[:action]
      rparams = @result[:params] || {}

      form_with(url: chat_confirm_path, data: { turbo_stream: true, action: 'submit->chat#confirmSubmission' }) do |f|
        input(type: 'hidden', name: 'record_action', value: action)
        rparams.each { |key, value| input(type: 'hidden', name: "record[#{key}]", value: value) }

        f.button(
          type:  'submit',
          class: 'flex items-center gap-1.5 px-3 py-1.5 bg-violet-600 text-white text-sm font-medium rounded-lg hover:bg-violet-700 transition-colors cursor-pointer'
        ) do
          render PhlexIcons::Lucide::Check.new(class: 'w-3.5 h-3.5')
          plain t('chat.message.btn_confirm')
        end
      end
    end

    def cancel_button
      button(
        type:  'button',
        class: 'px-3 py-1.5 text-slate-500 text-sm border border-slate-300 rounded-lg hover:bg-slate-50 transition-colors cursor-pointer',
        data:  { action: 'click->chat#cancelPreview' }
      ) { t('chat.message.btn_cancel') }
    end
  end
end
