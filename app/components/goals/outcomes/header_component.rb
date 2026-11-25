module Goals
  module Outcomes
    class HeaderComponent < ApplicationComponent
      include TopbarStyles
      include OutcomeLabels

      def initialize(title:, outcome:, action_label:, action_icon:, action_path:, unread_count:)
        @title = title
        @outcome = outcome
        @action_label = action_label
        @action_icon = action_icon
        @action_path = action_path
        @unread_count = unread_count
      end

      def view_template
        mobile_header
        desktop_header
      end

      private

      def mobile_header
        div(class: "#{PHONE_BAR} flex items-start gap-2 lg:hidden") do
          render BackLinkComponent.new(fallback: helpers.notifications_path, label: t('goals.outcomes.show.back'))
          div do
            h1(class: 'text-2xl font-bold text-slate-800 leading-tight') { @title }
            p(class: 'text-sm text-slate-500 mt-0.5') { period_label.full }
          end
        end
      end

      def desktop_header
        render DesktopTopbarComponent.new(title: @title, subtitle: desktop_subtitle, unread_count: @unread_count) do |topbar|
          topbar.with_actions { action_link }
        end
      end

      def action_link
        link_to(@action_path, class: 'flex items-center gap-2 bg-white border border-slate-200 rounded-lg ' \
                                       'px-3.5 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50') do
          render @action_icon.new(class: 'w-[15px] h-[15px] text-slate-500')
          plain " #{@action_label}"
        end
      end

      def desktop_subtitle
        t('goals.outcomes.show.desktop_subtitle', period: period_label.full, kind: kind_label.downcase,
                                                    metric: metric_label)
      end
    end
  end
end
