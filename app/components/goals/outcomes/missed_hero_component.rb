module Goals
  module Outcomes
    class MissedHeroComponent < ApplicationComponent
      include OutcomeLabels

      def initialize(outcome:)
        @outcome = outcome
      end

      def view_template
        div(class: 'rounded-2xl bg-white border border-slate-100 shadow-sm p-5 text-center') do
          ring_block
          kicker
          heading
          made_text
          stats_grid
        end
      end

      private

      def ring_block
        div(class: 'flex justify-center') do
          div(class: 'dc-pop lg:hidden') { render_ring(size: 132) }
          div(class: 'dc-pop hidden lg:flex') { render_ring(size: 156) }
        end
      end

      def render_ring(size:)
        render Goals::ProgressRingComponent.new(percent: @outcome.percent, color: '#f59e0b', size: size, stroke: 11) do
          span(class: 'text-3xl font-bold text-slate-800 tabular-nums') do
            plain @outcome.percent.to_s
            span(class: 'text-base font-medium text-slate-500') { '%' }
          end
          span(class: 'text-[10px] font-medium text-slate-400 uppercase tracking-wide') do
            t('goals.outcomes.missed.hero.percent_of_target')
          end
        end
      end

      def kicker
        p(class: 'text-xs font-semibold text-amber-700 uppercase tracking-wider mt-4') do
          plain t('goals.outcomes.show.hero.kicker', kind: kind_label, metric: metric_label)
        end
      end

      def heading
        h2(class: 'text-2xl lg:text-3xl font-bold text-slate-900 mt-1 leading-tight') do
          plain t("goals.outcomes.missed.hero.heading.#{@outcome.near ? 'near' : 'closed'}")
        end
      end

      def made_text
        p(class: 'text-sm text-slate-600 mt-2 leading-relaxed') do
          plain t("goals.outcomes.missed.hero.made_before.#{@outcome.goal.kind}", period: period_label.short)
          strong(class: 'text-slate-900') { format_currency(@outcome.achieved) }
          plain t('goals.outcomes.missed.hero.short_by')
          strong(class: 'text-slate-900') { format_currency(@outcome.shortfall) }
          plain t('goals.outcomes.missed.hero.short_after', target: format_currency(@outcome.target))
        end
      end

      def stats_grid
        div(class: 'grid grid-cols-3 gap-2 mt-5 pt-4 border-t border-slate-100 text-left') do
          render StatComponent.new(label: t('goals.outcomes.show.hero.target'), value: format_currency(@outcome.target))
          render StatComponent.new(label: t('goals.outcomes.show.hero.achieved'), value: format_currency(@outcome.achieved))
          render StatComponent.new(label: t('goals.outcomes.missed.hero.shortfall'),
                                   value: format_currency(@outcome.shortfall), tone: 'text-amber-700')
        end
      end
    end
  end
end
