module Goals
  class MonthlyGoalCardComponent < ApplicationComponent
    BADGE_SIZES = {
      compact: { box: 'mt-3 px-2.5 py-1.5 gap-1.5', icon: 'w-3 h-3', text: 'text-xs' },
      wide:    { box: 'mt-4 px-3 py-2 gap-2', icon: 'w-3.5 h-3.5', text: 'text-sm' }
    }.freeze

    def initialize(progress:, variant: :compact)
      @progress = progress
      @variant = variant
    end

    def view_template
      @variant == :wide ? wide_template : compact_template
    end

    private

    def compact_template
      div(class: 'bg-white rounded-2xl border-2 border-blue-200 p-5 shadow-sm') do
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
            div(class: 'flex items-center justify-between mb-2') do
              div(class: 'flex items-center gap-2 text-blue-700') do
                render PhlexIcons::Lucide::Target.new(class: 'w-4 h-4')
                span(class: 'text-xs font-bold uppercase tracking-wider') { t('goals.index.monthly.label') }
              end
              edit_link
            end
            p(class: 'text-4xl font-bold text-slate-900 tracking-tight tabular-nums') { format_currency(@progress[:current]) }
            p(class: 'text-sm text-slate-500 mt-1') do
              t('goals.index.monthly.of_target_metric', target: format_currency(@progress[:target]), metric: metric_label.downcase)
            end
            projection_badge
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
      div(class: 'flex items-center justify-between mb-3') do
        div(class: 'flex items-center gap-2') do
          div(class: 'w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center text-blue-600') do
            render PhlexIcons::Lucide::Target.new(class: 'w-4 h-4')
          end
          div do
            p(class: 'text-xs font-medium text-slate-500 uppercase tracking-wider') { t('goals.index.monthly.label') }
            p(class: 'text-sm font-semibold text-slate-700') { metric_label }
          end
        end
        div(class: 'flex items-center gap-2') do
          unless @progress[:ended]
            span(class: 'text-xs font-medium text-slate-400') do
              plain t('goals.index.monthly.days_left', count: @progress[:days_remaining])
            end
          end
          edit_link
        end
      end
    end

    def edit_link
      return if @progress[:goal].ended?

      link_to(helpers.edit_goal_path(@progress[:goal]),
              class: 'w-7 h-7 rounded-full bg-white border border-slate-200 flex items-center justify-center text-slate-500 hover:text-slate-700',
              aria:  { label: t('goals.index.edit_aria') },
              data:  { turbo_frame: 'modal' }) do
        render PhlexIcons::Lucide::Pencil.new(class: 'w-[14px] h-[14px]')
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

    def projection_badge
      return reached_badge if @progress[:reached]
      return missed_badge if @progress[:ended]
      return tracking_badge if @progress[:tracking]

      classic_projection_badge
    end

    def reached_badge
      badge('bg-emerald-50 border-emerald-200 text-emerald-700', PhlexIcons::Lucide::Check) do
        t('goals.index.monthly.reached', surplus: format_currency(@progress[:surplus]))
      end
    end

    def missed_badge
      badge('bg-rose-50 border-rose-200 text-rose-700') do
        t('goals.index.monthly.missed', shortfall: format_currency([@progress[:target] - @progress[:current], 0].max))
      end
    end

    def tracking_badge
      badge('bg-slate-50 border-slate-200 text-slate-600', PhlexIcons::Lucide::Clock) { t('goals.index.monthly.tracking') }
    end

    def classic_projection_badge
      on_track = @progress[:on_track]
      key = on_track ? 'goals.index.monthly.on_track_projection' : 'goals.index.monthly.at_risk_projection'
      colors = on_track ? 'bg-emerald-50 border-emerald-200 text-emerald-700' : 'bg-amber-50 border-amber-200 text-amber-700'

      badge(colors, PhlexIcons::Lucide::TrendingUp) { t(key, value: projection_text) }
    end

    def badge(colors, icon = nil, &)
      size = BADGE_SIZES.fetch(@variant)
      div(class: "#{size[:box]} border rounded-lg inline-flex items-center #{colors}") do
        render icon.new(class: size[:icon], 'stroke-width': '2.5') if icon
        span(class: "#{size[:text]} font-medium", &)
      end
    end

    def projection_text
      @variant == :wide ? format_currency(@progress[:projection]) : format_currency_short(@progress[:projection])
    end

    def metric_label
      t("goals.index.monthly.sublabel_#{@progress[:goal].metric}")
    end

    def metrics_grid
      div(class: 'mt-4 pt-4 border-t border-slate-100 grid grid-cols-3 gap-3') do
        metric_block(t('goals.index.monthly.remaining'), format_currency([@progress[:target] - @progress[:current], 0].max))
        metric_block(t('goals.index.monthly.per_day'), format_currency(@progress[:remaining_per_day]), middle: true)
        metric_block(t('goals.index.monthly.current_pace'), format_currency(pace))
      end
    end

    def metric_block(label, value, middle: false)
      border = middle ? ' border-x border-slate-100' : ''
      div(class: "text-center#{border}") do
        p(class: 'text-[10px] font-medium uppercase tracking-wide text-slate-500') { label }
        p(class: 'text-sm font-bold text-slate-800 mt-0.5') { value }
      end
    end

    def pace
      @progress[:daily_pace] || 0
    end
  end
end
