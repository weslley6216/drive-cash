module WeeklySummaries
  class WeekNavComponent < ApplicationComponent
    BUTTON_CLASSES = 'rounded-full bg-white border border-slate-200 flex items-center justify-center'.freeze

    def initialize(week:, return_to: nil, size: 'w-9 h-9')
      @week = week
      @return_to = return_to
      @size = size
    end

    def view_template
      div(class: 'flex items-center gap-1.5 flex-shrink-0') do
        previous_button
        next_button
      end
    end

    private

    def previous_button
      link_to(helpers.weekly_summary_path(@week.previous, return_to: @return_to), class: "#{@size} #{BUTTON_CLASSES} shadow-sm text-slate-600",
                                                                                  aria:  { label: t('weekly_summaries.show.previous_week') }) do
        render PhlexIcons::Lucide::ChevronLeft.new(class: 'w-[17px] h-[17px]')
      end
    end

    def next_button
      if @week.current?
        button(type: 'button', disabled: true, class: "#{@size} #{BUTTON_CLASSES} text-slate-300",
               aria: { label: t('weekly_summaries.show.next_week') }) do
          render PhlexIcons::Lucide::ChevronRight.new(class: 'w-[17px] h-[17px]')
        end
      else
        link_to(helpers.weekly_summary_path(@week.next, return_to: @return_to), class: "#{@size} #{BUTTON_CLASSES} shadow-sm text-slate-600",
                                                                                aria:  { label: t('weekly_summaries.show.next_week') }) do
          render PhlexIcons::Lucide::ChevronRight.new(class: 'w-[17px] h-[17px]')
        end
      end
    end
  end
end
