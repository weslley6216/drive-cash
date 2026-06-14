module Chat
  class ConfirmView < ApplicationView
    def initialize(success:, message:, action: nil, date: nil)
      @success = success
      @message = message
      @action  = action
      @date    = date.is_a?(Date) ? date : Date.current
    end

    def view_template
      raw turbo_stream.append('chat_messages') {
        div(class: 'flex flex-col gap-2') do
          div(class: 'flex items-start gap-2') do
            div(class: 'w-7 h-7 bg-violet-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5') do
              render PhlexIcons::Lucide::Sparkles.new(class: 'w-4 h-4 text-violet-600')
            end
            div(class: "bg-white border px-4 py-2.5 rounded-2xl rounded-tl-sm text-sm shadow-sm leading-relaxed #{bubble_style}") do
              plain message
            end
          end
          render_action_chips if @success
        end
      }
    end

    private

    def render_action_chips
      context = { month: @date.month, year: @date.year }

      div(class: 'flex flex-wrap gap-2 ml-9 mt-1') do
        ConfirmChips.for(@action).each do |chip|
          action_chip(public_send(chip.route, context), t(chip.label), frame: chip.frame)
        end
      end
    end

    def action_chip(url, label, frame:)
      a(
        href: url,
        data: { turbo_frame: frame },
        class: 'px-3 py-1.5 bg-slate-50 border border-slate-200 text-slate-600 text-xs font-medium rounded-full hover:bg-white hover:border-violet-300 hover:text-violet-600 transition-all shadow-sm active:scale-95 cursor-pointer'
      ) { label }
    end

    def message = @message

    def bubble_style
      @success ? 'border-green-200 text-green-800' : 'border-red-200 text-red-700'
    end
  end
end
