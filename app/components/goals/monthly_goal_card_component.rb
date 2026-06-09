module Goals
  class MonthlyGoalCardComponent < ApplicationComponent
    RING_SIZES = { compact: 120, wide: 200 }.freeze

    def initialize(progress:, variant: :compact)
      @progress = progress
      @variant = variant
    end

    def view_template
      @variant == :wide ? wide_template : compact_template
    end

    private

    def compact_template
      div(class: 'bg-white rounded-2xl border-2 border-blue-200 shadow-sm p-6 space-y-4') do
        card_header
        ring_section
        metrics_grid
      end
    end

    def wide_template
      div(class: 'bg-white rounded-2xl border-2 border-blue-200 p-7') do
        div(class: 'grid grid-cols-12 gap-6 items-center') do
          div(class: 'col-span-12 lg:col-span-3 flex justify-center') do
            render Goals::ProgressRingComponent.new(percent: @progress[:percent], size: 200, color: '#2563eb')
          end
          div(class: 'col-span-12 lg:col-span-5') do
            div(class: 'flex items-center gap-2 text-blue-700 mb-2') do
              render PhlexIcons::Lucide::Target.new(class: 'w-4 h-4')
              span(class: 'text-xs font-bold uppercase tracking-wider') { t('goals.index.monthly.label') }
            end
            p(class: 'text-4xl font-bold text-slate-900 tracking-tight tabular-nums') { format_currency(@progress[:current]) }
            p(class: 'text-sm text-slate-500 mt-1') { t('goals.index.monthly.of_target', target: format_currency(@progress[:target])) }
            projection_badge(mt: 'mt-4')
          end
          div(class: 'col-span-12 lg:col-span-4') do
            wide_metrics
          end
        end
      end
    end

    def wide_metrics
      div(class: 'grid grid-cols-3 gap-4') do
        wide_metric(t('goals.index.monthly.remaining'), format_currency([@progress[:target] - @progress[:current], 0].max))
        wide_metric(t('goals.index.monthly.per_day'), format_currency(@progress[:remaining_per_day]))
        wide_metric(t('goals.index.monthly.current_pace'), format_currency(pace))
      end
    end

    def wide_metric(label, value)
      div(class: 'text-center') do
        p(class: 'text-[10px] font-semibold uppercase tracking-wide text-slate-500') { label }
        p(class: 'text-base font-bold text-slate-900 tabular-nums mt-1') { value }
      end
    end

    def card_header
      div(class: 'flex items-center justify-between') do
        div(class: 'flex items-center gap-2') do
          div(class: 'w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center text-blue-600') do
            render PhlexIcons::Lucide::Target.new(class: 'w-4 h-4')
          end
          div do
            p(class: 'text-xs font-medium text-slate-500 uppercase tracking-wider') { t('goals.index.monthly.label') }
            p(class: 'text-sm font-semibold text-slate-700') { t("goals.index.monthly.sublabel_#{@progress[:goal].metric}") }
          end
        end
        span(class: 'text-xs font-medium text-slate-400') do
          plain t('goals.index.monthly.days_left', count: @progress[:days_remaining])
        end
      end
    end

    def ring_section
      div(class: 'flex items-center gap-5') do
        render Goals::ProgressRingComponent.new(percent: @progress[:percent], size: 120, color: '#2563eb')
        div(class: 'flex-1 min-w-0') do
          p(class: 'text-3xl font-bold text-slate-800 leading-none') { format_currency(@progress[:current]) }
          p(class: 'text-sm text-slate-500 mt-1') { t('goals.index.monthly.of_target', target: format_currency(@progress[:target])) }
          projection_badge
        end
      end
    end

    def projection_badge(mt: 'mt-3')
      on_track = @progress[:on_track]
      key    = on_track ? 'goals.index.monthly.on_track_projection' : 'goals.index.monthly.at_risk_projection'
      colors = on_track ? 'bg-emerald-50 border-emerald-200 text-emerald-700' : 'bg-amber-50 border-amber-200 text-amber-700'

      div(class: "#{mt} px-2.5 py-1.5 border rounded-lg inline-flex items-center gap-1.5 #{colors}") do
        render PhlexIcons::Lucide::TrendingUp.new(class: 'w-3 h-3', 'stroke-width': '2.5')
        span(class: 'text-xs font-medium') { t(key, value: format_currency(@progress[:projection])) }
      end
    end

    def metrics_grid
      div(class: 'grid grid-cols-3 pt-4 border-t border-slate-100') do
        metric_block(t('goals.index.monthly.remaining'), format_currency([@progress[:target] - @progress[:current], 0].max))
        metric_block(t('goals.index.monthly.per_day'), format_currency(@progress[:remaining_per_day]), middle: true)
        metric_block(t('goals.index.monthly.current_pace'), format_currency(pace))
      end
    end

    def metric_block(label, value, middle: false)
      border = middle ? ' border-x border-slate-100' : ''
      div(class: "text-center#{border}") do
        p(class: 'text-[10px] font-semibold uppercase tracking-wide text-slate-500') { label }
        p(class: 'text-sm font-bold text-slate-800 mt-0.5') { value }
      end
    end

    def pace
      goal = @progress[:goal]
      total_days = (goal.period_end - goal.period_start).to_i + 1
      total_days.zero? ? 0 : @progress[:current] / total_days
    end
  end
end
