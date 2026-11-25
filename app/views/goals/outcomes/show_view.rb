module Goals
  module Outcomes
    class ShowView < ApplicationView
      def initialize(outcome:, confetti:, unread_count:)
        @outcome = outcome
        @confetti = confetti
        @unread_count = unread_count
      end

      def view_template
        screen = Goals::Outcomes.const_get("#{@outcome.state.camelize}ScreenComponent", false)
          .new(outcome: @outcome, unread_count: @unread_count)

        render LayoutComponent.new(title: screen.title, bottom_nav: :goals, sidebar_nav: :goals,
                                   turbo_cache: false) do
          div(class: 'relative flex-1 flex flex-col min-h-0') do
            render Goals::Outcomes::ConfettiComponent.new if @confetti
            render screen
          end
        end
      end
    end
  end
end
