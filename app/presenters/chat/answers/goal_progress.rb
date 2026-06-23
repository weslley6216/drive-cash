module Chat
  module Answers
    class GoalProgress
      include Formatting

      def initialize(data)
        @data = data
      end

      def call
        active = find_active_goal
        return I18n.t('chat.answer.no_goal') unless active

        progress = @data[active]
        remaining = progress[:target] - progress[:current]

        if progress[:on_track]
          per_day = progress[:remaining_per_day].to_f
          I18n.t('chat.answer.goal_on_track',
                 remaining: format_currency(remaining),
                 per_day:   format_currency(per_day))
        else
          per_day = progress[:remaining_per_day].to_f
          I18n.t('chat.answer.goal_off_track', per_day: format_currency(per_day))
        end
      end

      private

      def find_active_goal
        %i[monthly annual weekly].find { |kind| @data[kind].present? }
      end
    end
  end
end
