module Goals
  class MonthlyGoalCardComponent < ApplicationComponent
    RING_SIZES = { compact: 120, wide: 220 }.freeze

    def initialize(progress:, variant: :compact)
      @progress = progress
      @variant = variant
    end

    def view_template
      div(class: card_classes) do
        div(class: header_classes) do
          render Goals::ProgressRingComponent.new(percent: @progress[:percent], size: ring_size, color: '#2563eb')
          div(class: 'flex-1 min-w-0') do
            p(class: 'text-sm font-medium text-slate-500') { t('goals.index.monthly.label') }
            p(class: 'text-2xl font-bold text-slate-900 mt-1') { brl(@progress[:current]) }
            p(class: 'text-xs text-slate-500 mt-0.5') do
              plain t('goals.index.monthly.sublabel')
              plain ' · '
              plain brl(@progress[:target])
            end
            p(class: 'text-xs text-slate-500 mt-2') do
              plain t('goals.index.monthly.days_left', count: @progress[:days_remaining])
            end
          end
        end
        metrics_grid
        projection_line
      end
    end

    private

    def ring_size
      RING_SIZES.fetch(@variant, RING_SIZES[:compact])
    end

    def card_classes
      'bg-white rounded-2xl border border-slate-200 shadow-sm p-6 space-y-5'
    end

    def header_classes
      @variant == :wide ? 'flex items-center gap-8' : 'flex items-center gap-4'
    end

    def metrics_grid
      div(class: 'grid grid-cols-3 gap-3 pt-4 border-t border-slate-100') do
        metric_block(t('goals.index.monthly.remaining'), brl([@progress[:target] - @progress[:current], 0].max))
        metric_block(t('goals.index.monthly.per_day'), brl(@progress[:remaining_per_day]))
        metric_block(t('goals.index.monthly.current_pace'), brl(pace))
      end
    end

    def metric_block(label, value)
      div(class: 'text-center') do
        p(class: 'text-[11px] uppercase tracking-wide text-slate-500') { label }
        p(class: 'text-sm font-semibold text-slate-900 mt-1') { value }
      end
    end

    def pace
      goal = @progress[:goal]
      total_days = (goal.period_end - goal.period_start).to_i + 1
      total_days.zero? ? 0 : @progress[:current] / total_days
    end

    def projection_line
      key = @progress[:on_track] ? 'goals.index.monthly.on_track_projection' : 'goals.index.monthly.at_risk_projection'
      color = @progress[:on_track] ? 'text-emerald-600' : 'text-amber-600'

      p(class: "text-xs font-medium #{color}") do
        plain t(key, value: brl(@progress[:projection]))
      end
    end

    def brl(value)
      helpers.number_to_currency(value, unit: 'R$', separator: ',', delimiter: '.')
    end
  end
end
