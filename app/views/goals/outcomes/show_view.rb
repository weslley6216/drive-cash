module Goals
  module Outcomes
    class ShowView < ApplicationView
      include TopbarStyles
      include OutcomeLabels

      def initialize(outcome:, confetti:)
        @outcome = outcome
        @confetti = confetti
      end

      def view_template
        render LayoutComponent.new(title: t('goals.outcomes.show.title'), bottom_nav: :goals, sidebar_nav: :goals,
                                   turbo_cache: false) do
          div(class: 'relative overflow-hidden flex-1 flex flex-col min-h-0 bg-gradient-to-b ' \
                     'from-emerald-50 to-slate-50 lg:from-emerald-50/60') do
            render Goals::Outcomes::ConfettiComponent.new if @confetti
            render ScreenComponent.new do |screen|
              screen.with_header do
                mobile_header
                desktop_header
              end
              screen.with_content { body_section }
            end
          end
        end
      end

      private

      def mobile_header
        div(class: "#{PHONE_BAR} flex items-start gap-2 lg:hidden") do
          link_to(helpers.notifications_path, class: 'p-1 -ml-1 mt-0.5 text-slate-500',
                                              aria:  { label: t('goals.outcomes.show.back') }) do
            render PhlexIcons::Lucide::ArrowLeft.new(class: 'w-[22px] h-[22px]')
          end
          div do
            h1(class: 'text-2xl font-bold text-slate-800 leading-tight') { t('goals.outcomes.show.title') }
            p(class: 'text-sm text-slate-500 mt-0.5') { period_label.full }
          end
        end
      end

      def desktop_header
        div(class: "#{DESKTOP_BAR} hidden lg:flex items-center justify-between") do
          div do
            h1(class: 'text-2xl font-bold text-slate-900 tracking-tight') { t('goals.outcomes.show.title') }
            p(class: 'text-sm text-slate-500 mt-0.5') { desktop_subtitle }
          end
          link_to(helpers.goals_path, class: 'flex items-center gap-2 bg-white border border-slate-200 rounded-lg ' \
                                             'px-3.5 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50') do
            render PhlexIcons::Lucide::Target.new(class: 'w-[15px] h-[15px] text-slate-500')
            plain " #{t('goals.outcomes.show.view_goals')}"
          end
        end
      end

      def desktop_subtitle
        t('goals.outcomes.show.desktop_subtitle', period: period_label.full, kind: kind_label.downcase,
                                                    metric: metric_label)
      end

      def body_section
        div(class: 'max-w-5xl grid grid-cols-12 gap-4 lg:gap-5 items-start pb-10') do
          div(class: 'col-span-12 lg:col-span-7') { render Goals::Outcomes::HeroComponent.new(outcome: @outcome) }
          div(class: 'col-span-12 lg:col-span-5 flex flex-col gap-4 lg:gap-5') do
            div(class: 'lg:order-2') { render Goals::Outcomes::JourneyComponent.new(outcome: @outcome) }
            div(class: 'lg:order-1') { render Goals::Outcomes::NextStepComponent.new(outcome: @outcome) }
          end
        end
        view_all_goals_link
      end

      def view_all_goals_link
        link_to(helpers.goals_path,
                class: 'lg:hidden w-full py-2 text-sm font-medium text-blue-600 flex items-center ' \
                       'justify-center gap-1.5') do
          plain t('goals.outcomes.show.view_all_goals')
          render PhlexIcons::Lucide::ArrowRight.new(class: 'w-[14px] h-[14px]')
        end
      end
    end
  end
end
