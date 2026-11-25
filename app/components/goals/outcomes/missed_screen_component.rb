module Goals
  module Outcomes
    class MissedScreenComponent < ApplicationComponent
      HISTORY_PARAMS = {
        'weekly'  => ->(period) { { week: Calendars::Week.containing(period.first).to_param } },
        'monthly' => ->(period) { { year: period.first.year, month: period.first.month } },
        'annual'  => ->(period) { { year: period.first.year } }
      }.freeze

      def initialize(outcome:, unread_count:)
        @outcome = outcome
        @unread_count = unread_count
      end

      def title = I18n.t('goals.outcomes.missed.title')

      def view_template
        div(class: 'flex-1 flex flex-col min-h-0 bg-gradient-to-br from-slate-50 to-slate-100 lg:bg-none lg:bg-slate-50') do
          render ScreenComponent.new do |screen|
            screen.with_header do
              render HeaderComponent.new(title: title, outcome: @outcome, action_label: view_entries_label,
                                         action_icon: PhlexIcons::Lucide::List, action_path: history_link,
                                         unread_count: @unread_count)
            end
            screen.with_content { body_section }
          end
        end
      end

      private

      def body_section
        div(class: 'max-w-5xl grid grid-cols-12 gap-4 lg:gap-5 items-start lg:pb-10') do
          div(class: 'col-span-12 lg:col-span-7') { render MissedHeroComponent.new(outcome: @outcome) }
          div(class: 'col-span-12 lg:col-span-5 flex flex-col gap-4 lg:gap-5') do
            div(class: 'lg:order-2') { render WentWellComponent.new(outcome: @outcome) }
            div(class: 'lg:order-1') { render MissedNextStepComponent.new(outcome: @outcome) }
          end
        end
        footer_link
      end

      def footer_link
        link_to(history_link, class: 'lg:hidden w-full mt-4 py-2 text-sm font-medium text-blue-600 flex items-center ' \
                                      'justify-center gap-1.5') do
          plain view_entries_label
          render PhlexIcons::Lucide::ArrowRight.new(class: 'w-[14px] h-[14px]')
        end
      end

      def view_entries_label
        t("goals.outcomes.missed.view_entries.#{@outcome.goal.kind}")
      end

      def history_link
        helpers.history_path(**HISTORY_PARAMS.fetch(@outcome.goal.kind).call(period))
      end

      def period
        @outcome.goal.period_start..@outcome.goal.period_end
      end
    end
  end
end
