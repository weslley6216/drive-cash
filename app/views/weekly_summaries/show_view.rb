module WeeklySummaries
  class ShowView < ApplicationView
    include TopbarStyles
    include WeekRangeLabel

    def initialize(summary:)
      @summary = summary
    end

    def view_template
      render LayoutComponent.new(title: t('weekly_summaries.show.title'), bottom_nav: :home, sidebar_nav: :home) do
        render ScreenComponent.new do |screen|
          screen.with_header do
            mobile_header
            desktop_header
          end
          screen.with_content { body_section }
        end
      end
    end

    private

    def mobile_header
      div(class: "#{PHONE_BAR} flex items-start gap-2 lg:hidden") do
        link_to(helpers.notifications_path,
                class: 'p-1 -ml-1 mt-0.5 text-slate-500',
                aria:  { label: t('weekly_summaries.show.back') }) do
          render PhlexIcons::Lucide::ArrowLeft.new(class: 'w-[22px] h-[22px]')
        end
        div do
          h1(class: 'text-2xl font-bold text-slate-800') { t('weekly_summaries.show.title') }
          p(class: 'text-sm text-slate-500') { week_range_text(@summary.week) }
        end
        div(class: 'ml-auto') { render WeekNavComponent.new(week: @summary.week) }
      end
    end

    def desktop_header
      div(class: "#{DESKTOP_BAR} hidden lg:flex items-center justify-between") do
        div do
          h1(class: 'text-2xl font-bold text-slate-900 tracking-tight') { t('weekly_summaries.show.title') }
          p(class: 'text-sm text-slate-500 mt-0.5') { week_range_text(@summary.week, with_year: true) }
        end
        div(class: 'flex items-center gap-3') do
          render WeekNavComponent.new(week: @summary.week, size: 'w-10 h-10')
          cta_link('bg-blue-600 hover:bg-blue-700 text-white rounded-lg px-4 py-2 text-sm font-semibold ' \
                   'flex items-center gap-2')
        end
      end
    end

    def body_section
      div(class: 'max-w-5xl grid grid-cols-12 gap-4 lg:gap-5 items-start lg:pb-10') do
        div(class: 'col-span-12 lg:col-span-5 space-y-4 lg:space-y-5') do
          render HeroComponent.new(summary: @summary)
          render GoalComponent.new(progress: @summary.goal) if @summary.goal
        end
        div(class: 'col-span-12 lg:col-span-7 flex flex-col gap-4 lg:gap-5') do
          render DailyBarsComponent.new(week: @summary.week, daily_profits: @summary.daily_profits,
                                        best_day_index: @summary.best_day_index, empty_days: @summary.empty_days,
                                        blank_week: @summary.blank_week)
          render TopCategoriesComponent.new(categories: @summary.top_categories, total: @summary.expenses_total)
          p(class: 'hidden lg:block text-sm') { analysis_link('font-medium text-blue-600 hover:underline') }
        end
      end
      mobile_footer
    end

    def mobile_footer
      div(class: 'lg:hidden mt-4 pb-10 space-y-4') do
        cta_link('w-full bg-blue-600 text-white rounded-xl py-3 text-sm font-semibold ' \
                 'flex items-center justify-center gap-2')
        analysis_link('block w-full py-1 text-center text-sm font-medium text-blue-600')
      end
    end

    def cta_link(css_class)
      link_to(helpers.history_path(week: @summary.week.to_param), class: css_class) do
        plain t('weekly_summaries.show.cta')
        render PhlexIcons::Lucide::ArrowRight.new(class: 'w-[15px] h-[15px]')
      end
    end

    def analysis_link(css_class)
      link_to(helpers.analysis_path(year: monday.year, month: monday.month), class: css_class) do
        plain t('weekly_summaries.show.analysis_link', month: I18n.t('date.month_names')[monday.month])
      end
    end

    def monday = @summary.week.monday
  end
end
