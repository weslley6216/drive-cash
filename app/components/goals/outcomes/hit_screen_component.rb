module Goals
  module Outcomes
    class HitScreenComponent < ApplicationComponent
      def initialize(outcome:)
        @outcome = outcome
      end

      def title = I18n.t('goals.outcomes.show.title')

      def view_template
        div(class: 'flex-1 flex flex-col min-h-0 bg-gradient-to-b from-emerald-50 to-slate-50 lg:from-emerald-50/60') do
          render HeaderComponent.new(title: title, outcome: @outcome, action_label: t('goals.outcomes.show.view_goals'),
                                     action_icon: PhlexIcons::Lucide::Target, action_path: helpers.goals_path)
          body_section
        end
      end

      private

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
