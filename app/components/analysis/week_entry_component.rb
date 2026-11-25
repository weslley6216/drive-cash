module Analysis
  class WeekEntryComponent < ApplicationComponent
    include WeekRangeLabel

    def initialize(week:, href:)
      @week = week
      @href = href
    end

    def view_template
      a(
        href:  @href,
        data:  { turbo_frame: '_top' },
        class: 'w-full flex items-center gap-3 bg-white rounded-xl shadow-sm border border-slate-100 px-4 py-3 text-left lg:hidden'
      ) do
        icon_bubble
        labels
        render PhlexIcons::Lucide::ChevronRight.new(class: 'w-4 h-4 text-slate-400')
      end
    end

    private

    def icon_bubble
      div(class: 'w-9 h-9 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center flex-shrink-0') do
        render PhlexIcons::Lucide::ChartColumn.new(class: 'w-[17px] h-[17px]')
      end
    end

    def labels
      div(class: 'flex-1 min-w-0') do
        p(class: 'text-sm font-semibold text-slate-800') { I18n.t('analysis.show_view.week_entry.title') }
        p(class: 'text-xs text-slate-500 truncate') { I18n.t('analysis.show_view.week_entry.subtitle', range: week_range_text(@week)) }
      end
    end
  end
end
