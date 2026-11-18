module Goals
  module Outcomes
    class HeaderComponent < ApplicationComponent
      include TopbarStyles
      include OutcomeLabels

      def initialize(title:, outcome:, action_label:, action_icon:, action_path:)
        @title = title
        @outcome = outcome
        @action_label = action_label
        @action_icon = action_icon
        @action_path = action_path
      end

      def view_template
        mobile_header
        desktop_header
      end

      private

      def mobile_header
        div(class: "#{PHONE_BAR} flex items-start gap-2 lg:hidden") do
          link_to(helpers.notifications_path, class: 'p-1 -ml-1 mt-0.5 text-slate-500',
                                              aria:  { label: t('goals.outcomes.show.back') }) do
            render PhlexIcons::Lucide::ArrowLeft.new(class: 'w-[22px] h-[22px]')
          end
          div do
            h1(class: 'text-2xl font-bold text-slate-800 leading-tight') { @title }
            p(class: 'text-sm text-slate-500 mt-0.5') { period_label.full }
          end
        end
      end

      def desktop_header
        div(class: "#{DESKTOP_BAR} hidden lg:flex items-center justify-between") do
          div do
            h1(class: 'text-2xl font-bold text-slate-900 tracking-tight') { @title }
            p(class: 'text-sm text-slate-500 mt-0.5') { desktop_subtitle }
          end
          link_to(@action_path, class: 'flex items-center gap-2 bg-white border border-slate-200 rounded-lg ' \
                                       'px-3.5 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50') do
            render @action_icon.new(class: 'w-[15px] h-[15px] text-slate-500')
            plain " #{@action_label}"
          end
        end
      end

      def desktop_subtitle
        t('goals.outcomes.show.desktop_subtitle', period: period_label.full, kind: kind_label.downcase,
                                                    metric: metric_label)
      end
    end
  end
end
