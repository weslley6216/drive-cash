module Goals
  module Outcomes
    class HeroComponent < ApplicationComponent
      include OutcomeLabels

      def initialize(outcome:)
        @outcome = outcome
      end

      def view_template
        div(class: 'rounded-2xl bg-white border-2 border-emerald-200 shadow-sm p-5 text-center') do
          ring_block
          kicker
          heading
          made_text
          above_pill
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
        render Goals::ProgressRingComponent.new(percent: @outcome.percent, color: '#10b981', size: size, stroke: 11) do
          span(class: 'w-14 h-14 rounded-full bg-emerald-50 text-emerald-600 flex items-center justify-center') do
            render PhlexIcons::Lucide::Trophy.new(class: 'w-[28px] h-[28px]')
          end
        end
      end

      def kicker
        p(class: 'text-xs font-semibold text-emerald-700 uppercase tracking-wider mt-4') do
          plain t('goals.outcomes.show.hero.kicker', kind: kind_label, metric: metric_label)
        end
      end

      def heading
        h2(class: 'text-2xl lg:text-3xl font-bold text-slate-900 mt-1 leading-tight') do
          plain t('goals.outcomes.show.hero.heading', period: period_label.short)
        end
      end

      def made_text
        p(class: 'text-sm text-slate-600 mt-2 leading-relaxed') do
          plain t('goals.outcomes.show.hero.made_before')
          strong(class: 'text-slate-900') { format_currency(@outcome.achieved) }
          plain t('goals.outcomes.show.hero.made_after', metric: metric_label, period: period_label.short)
        end
      end

      def above_pill
        span(class: 'inline-flex items-center gap-1.5 mt-3 px-3 py-1.5 rounded-full bg-emerald-50 ' \
                    'border border-emerald-200 text-xs font-semibold text-emerald-700 tabular-nums') do
          render PhlexIcons::Lucide::TrendingUp.new(class: 'w-[13px] h-[13px]')
          plain t('goals.outcomes.show.hero.above', surplus: format_currency(@outcome.surplus),
                                                    percent: @outcome.percent.round)
        end
      end

      def stats_grid
        div(class: 'grid grid-cols-3 gap-2 mt-5 pt-4 border-t border-slate-100 text-left') do
          render StatComponent.new(label: t('goals.outcomes.show.hero.target'), value: format_currency(@outcome.target))
          render StatComponent.new(label: t('goals.outcomes.show.hero.achieved'),
                                   value: format_currency(@outcome.achieved), tone: 'text-emerald-700')
          render StatComponent.new(label: t('goals.outcomes.show.hero.hit_on'),
                                   value: I18n.l(@outcome.hit_on, format: :day_abbr),
                                   sub:   t('goals.outcomes.show.hero.days_before_end', count: @outcome.days_before_end))
        end
      end
    end
  end
end
