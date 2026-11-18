module WeeklySummaries
  class GoalComponent < ApplicationComponent
    def initialize(progress:)
      @progress = progress
    end

    def view_template
      div(class: 'bg-white rounded-xl shadow-sm border border-slate-100 p-4') do
        header_row
        div(class: 'h-2 bg-slate-100 rounded-full overflow-hidden mt-3') do
          div(class: "h-full rounded-full #{bar_color}", style: "width: #{bar_width}%")
        end
        outcome_link
      end
    end

    private

    def header_row
      div(class: 'flex items-center justify-between gap-3') do
        div(class: 'flex items-center gap-2 min-w-0') do
          div(class: "w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 #{icon_classes}") do
            render PhlexIcons::Lucide::Target.new(class: 'w-[16px] h-[16px]')
          end
          div(class: 'min-w-0') do
            p(class: 'text-sm font-semibold text-slate-800') { t('weekly_summaries.show.goal.title') }
            p(class: 'text-xs text-slate-500 tabular-nums') { progress_text }
          end
        end
        span(class: "text-xs font-semibold px-2 py-1 rounded-full tabular-nums #{percent_classes}") do
          "#{@progress.percent}%"
        end
      end
    end

    def outcome_link
      link_to(helpers.goal_outcome_path(@progress.goal, @progress.goal.period_start),
              class: 'mt-3 w-fit text-xs font-semibold text-blue-600 flex items-center gap-1') do
        plain t('weekly_summaries.show.goal.link')
        render PhlexIcons::Lucide::ArrowRight.new(class: 'w-[13px] h-[13px]')
      end
    end

    def progress_text
      t('weekly_summaries.show.goal.progress', achieved: format_currency(@progress.achieved),
                                               target:   format_currency(@progress.goal.target_amount))
    end

    def icon_classes
      @progress.hit ? 'bg-emerald-100 text-emerald-600' : 'bg-amber-100 text-amber-600'
    end

    def percent_classes
      @progress.hit ? 'text-emerald-700 bg-emerald-50' : 'text-amber-700 bg-amber-50'
    end

    def bar_color
      @progress.hit ? 'bg-emerald-500' : 'bg-amber-500'
    end

    def bar_width
      [@progress.percent, 100].min
    end
  end
end
