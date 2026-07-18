module Goals
  class AnnualBarComponent < ApplicationComponent
    DAYS_PER_MONTH = 30

    def initialize(progress:)
      @progress = progress
    end

    def view_template
      width = @progress[:percent].to_f.clamp(0, 100).round

      div(class: 'bg-white rounded-xl border border-slate-200 p-5') do
        div(class: 'flex items-center justify-between mb-4') do
          div(class: 'flex items-center gap-3') do
            div(class: 'w-8 h-8 rounded-full bg-purple-100 flex items-center justify-center text-purple-600') do
              render PhlexIcons::Lucide::Star.new(class: 'w-4 h-4')
            end
            div do
              p(class: 'text-sm font-semibold text-slate-800') { t('goals.index.annual.label') }
              p(class: 'text-xs text-slate-500') { year_label }
            end
          end
          edit_link
        end
        p(class: 'text-2xl font-bold text-slate-900 tabular-nums') { format_currency(@progress[:current]) }
        p(class: 'text-xs text-slate-500 mt-0.5') { t('goals.index.annual.of_target', target: format_currency(@progress[:target])) }
        div(class: 'h-2 bg-slate-100 rounded-full overflow-hidden mt-3') do
          div(class: 'h-full bg-gradient-to-r from-purple-400 to-purple-600 rounded-full', style: "width: #{width}%")
        end
        p(class: 'text-xs font-medium text-purple-700 mt-2') do
          plain "#{@progress[:percent].to_f.round(1)}% · "
          plain t('goals.index.annual.remaining_months', count: months_remaining)
        end
      end
    end

    private

    def edit_link
      goal = @progress[:goal]
      return unless goal
      return if goal.ended?

      link_to(helpers.edit_goal_path(goal),
              class:      'w-7 h-7 rounded-full bg-white border border-slate-200 flex items-center justify-center text-slate-500 hover:text-slate-700',
              aria_label: t('goals.index.edit_aria'),
              data:       { turbo_frame: 'modal' }) do
        render PhlexIcons::Lucide::Pencil.new(class: 'w-[14px] h-[14px]')
      end
    end

    def year_label
      goal = @progress[:goal]
      goal&.period_start&.year&.to_s || Date.current.year.to_s
    end

    def months_remaining
      (@progress[:days_remaining].to_f / DAYS_PER_MONTH).round
    end
  end
end
