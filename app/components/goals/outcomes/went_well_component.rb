module Goals
  module Outcomes
    class WentWellComponent < ApplicationComponent
      include CardStyles

      def initialize(outcome:)
        @outcome = outcome
      end

      def view_template
        div(class: "#{CARD} p-4") do
          h3(class: 'text-sm font-semibold text-slate-800 mb-3') { t('goals.outcomes.missed.went_well.title') }
          render PaceStatsComponent.new(outcome: @outcome)
          track_record_line if @outcome.track_record
        end
      end

      private

      def track_record_line
        p(class: 'flex items-center gap-2 mt-4 pt-3 border-t border-slate-100 text-xs text-slate-600') do
          span(class: 'w-6 h-6 rounded-full bg-emerald-50 text-emerald-600 flex items-center justify-center flex-shrink-0') do
            render PhlexIcons::Lucide::Check.new(class: 'w-[13px] h-[13px]')
          end
          plain t("goals.outcomes.missed.went_well.track_record.#{@outcome.goal.kind}",
                  hits: @outcome.track_record.hits, total: @outcome.track_record.total)
        end
      end
    end
  end
end
