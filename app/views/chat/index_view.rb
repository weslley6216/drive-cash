module Chat
  class IndexView < ApplicationView
    include Formatting

    def initialize(messages: [])
      @messages = messages
    end

    def view_template
      render LayoutComponent.new(title: "DriveCash — #{t('chat.index.header')}") do
        div(
          class: 'flex flex-col',
          style: 'height: calc(100dvh - 4rem)',
          data:  { controller: 'chat speech' }
        ) do
          header_section
          messages_section
          input_section
          ui_templates
        end

        turbo_frame_tag 'modal'
      end
    end

    private

    def header_section
      div(class: 'flex items-center justify-between mb-4 flex-shrink-0') do
        div(class: 'flex items-center gap-3') do
          link_to(root_path, class: 'text-slate-400 hover:text-slate-600 transition-colors p-1') do
            render PhlexIcons::Lucide::ArrowLeft.new(class: 'w-5 h-5')
          end

          div do
            h1(class: 'text-lg font-bold text-slate-800') { t('chat.index.header') }
            p(class: 'text-xs text-slate-500') { t('chat.index.subtitle') }
          end
        end

        link_to(
          chat_clear_path,
          data:  { turbo_method: :delete },
          class: 'text-xs text-slate-400 hover:text-red-500 transition-colors'
        ) { t('chat.index.clear') }
      end
    end

    def messages_section
      div(
        id:    'chat_messages',
        class: 'flex-1 overflow-y-auto space-y-4 pb-4',
        data:  { chat_target: 'messages', controller: 'autoscroll' }
      ) do
        @messages.empty? ? empty_state : render_history
      end
    end

    def empty_state
      div(class: 'flex flex-col items-center justify-center h-full text-center px-8 gap-3') do
        div(class: 'w-16 h-16 bg-violet-100 rounded-full flex items-center justify-center') do
          render PhlexIcons::Lucide::Sparkles.new(class: 'w-8 h-8 text-violet-600')
        end
        p(class: 'font-medium text-slate-700') { t('chat.index.empty_title') }
        p(class: 'text-sm text-slate-500') { t('chat.index.empty_ex1') }
        p(class: 'text-sm text-slate-500') { t('chat.index.empty_ex2') }
      end
    end

    def render_history
      @messages.each do |message|
        if from_user?(message)
          user_bubble(message[:content])
        else
          ai_bubble(message[:summary].presence || message[:content])
        end
      end
    end

    def from_user?(message) = message[:role].to_s == 'user'

    def user_bubble(text)
      div(class: 'flex justify-end') do
        div(class: 'bg-blue-600 text-white px-4 py-2.5 rounded-2xl rounded-tr-sm max-w-[80%] text-sm leading-relaxed') { plain text }
      end
    end

    def ai_bubble(text)
      div(class: 'flex items-start gap-2') do
        div(class: 'w-7 h-7 bg-violet-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5') do
          render PhlexIcons::Lucide::Sparkles.new(class: 'w-4 h-4 text-violet-600')
        end
        div(class: 'bg-white border border-slate-200 px-4 py-2.5 rounded-2xl rounded-tl-sm max-w-[80%] text-sm text-slate-700 shadow-sm leading-relaxed') do
          plain text
        end
      end
    end

    def input_section
      div(class: 'flex-shrink-0 pt-4 border-t border-slate-200') do
        form_with(
          url:  chat_message_path,
          data: { loading_skip: true, action: 'submit->chat#send turbo:submit-end->chat#clearInput' }
        ) do |f|
          div(class: 'flex gap-2 items-end') do
            div(class: 'flex-1 relative') do
              textarea(
                name:         'message',
                placeholder:  t('chat.index.placeholder'),
                rows:         1,
                autocomplete: 'off',
                class:        'w-full px-4 py-3 pr-12 rounded-2xl border border-slate-300 focus:outline-none focus:ring-2 focus:ring-violet-500 focus:border-transparent resize-none text-sm bg-white',
                data:         { chat_target: 'input', speech_target: 'input', action: 'keydown.enter->chat#handleEnter' }
              )
              button(
                type:  'button',
                class: 'absolute right-3 bottom-[0.9rem] text-slate-400 hover:text-violet-600 transition-colors cursor-pointer',
                title: t('chat.index.btn_speak'),
                data:  { action: 'click->speech#toggle', speech_target: 'mic' }
              ) { render PhlexIcons::Lucide::Mic.new(class: 'w-4 h-4') }
            end

            button(
              type:  'submit',
              class: 'flex items-center justify-center w-11 h-11 bg-violet-600 text-white rounded-full hover:bg-violet-700 active:scale-95 transition-all cursor-pointer flex-shrink-0',
              data:  { chat_target: 'submit' }
            ) { render PhlexIcons::Lucide::Send.new(class: 'w-4 h-4') }
          end
        end
      end
    end

    def ui_templates
      template(data: { chat_target: 'userTemplate' }) do
        div(class: 'flex justify-end') do
          div(class: 'bg-blue-600 text-white px-4 py-2.5 rounded-2xl rounded-tr-sm max-w-[80%] text-sm leading-relaxed', data: { message_content: '' })
        end
      end

      template(data: { chat_target: 'typingTemplate' }) do
        div(id: 'chat_typing', class: 'flex items-start gap-2') do
          div(class: 'w-7 h-7 bg-violet-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5') do
            render PhlexIcons::Lucide::Sparkles.new(class: 'w-4 h-4 text-violet-600')
          end
          div(class: 'bg-white border border-slate-200 px-4 py-3 rounded-2xl rounded-tl-sm shadow-sm flex items-center gap-1') do
            span(class: 'w-2 h-2 bg-slate-400 rounded-full animate-bounce', style: 'animation-delay: 0ms') { }
            span(class: 'w-2 h-2 bg-slate-400 rounded-full animate-bounce', style: 'animation-delay: 150ms') { }
            span(class: 'w-2 h-2 bg-slate-400 rounded-full animate-bounce', style: 'animation-delay: 300ms') { }
          end
        end
      end
    end
  end
end
