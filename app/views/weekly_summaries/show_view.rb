module WeeklySummaries
  class ShowView < ApplicationView
    include CategoryPalette

    def initialize(summary:)
      @summary = summary
    end

    def view_template
      render LayoutComponent.new(title: t('weekly_summaries.show.title'), bottom_nav: :more, sidebar_nav: :more) do
        div(class: 'max-w-2xl lg:mx-auto') do
          mobile_header
          desktop_header
          body_section
        end
      end
    end

    private

    def mobile_header
      div(class: 'lg:hidden px-1 pt-2 pb-3 flex items-start gap-2') do
        link_to(helpers.notifications_path,
                class: 'p-1 -ml-1 mt-0.5 text-slate-500',
                aria:  { label: t('weekly_summaries.show.back') }) do
          render PhlexIcons::Lucide::ArrowLeft.new(class: 'w-[22px] h-[22px]')
        end
        div do
          h1(class: 'text-2xl font-bold text-slate-800') { t('weekly_summaries.show.title') }
          p(class: 'text-sm text-slate-500') { range_text }
        end
      end
    end

    def desktop_header
      div(class: 'hidden lg:block mb-6') do
        h1(class: 'text-2xl font-bold text-slate-800') { t('weekly_summaries.show.title') }
        p(class: 'text-sm text-slate-500 mt-1') { range_text }
      end
    end

    def body_section
      div(class: 'px-1 lg:px-0 pb-10 space-y-4') do
        profit_card
        render DailyBarsComponent.new(week: @summary.week, daily_profits: @summary.daily_profits,
                                      best_day_index: @summary.best_day_index)
        top_expense_card if @summary.top_category
        cta
      end
    end

    def profit_card
      div(class: 'bg-white rounded-xl shadow-sm border border-slate-100 p-4') do
        p(class: 'text-xs font-medium text-slate-500') { t('weekly_summaries.show.profit') }
        p(class: 'text-3xl font-bold text-slate-900 mt-1') { format_currency(@summary.profit) }
        div(class: 'grid grid-cols-3 gap-2 mt-4 pt-4 border-t border-slate-100') do
          metric(t('weekly_summaries.show.trips'), @summary.trips)
          metric(t('weekly_summaries.show.days_worked'), @summary.days_worked)
          metric(t('weekly_summaries.show.per_km'), per_km_text)
        end
      end
    end

    def metric(label, value)
      div do
        p(class: 'text-[11px] text-slate-500') { label }
        p(class: 'text-base font-bold text-slate-800') { value.to_s }
      end
    end

    def per_km_text
      @summary.per_km ? format_currency(@summary.per_km) : t('weekly_summaries.show.empty_value')
    end

    def top_expense_card
      top_category = @summary.top_category
      color = category_color(top_category.key)

      div(class: 'bg-white rounded-xl shadow-sm border border-slate-100 p-4') do
        h3(class: 'text-sm font-semibold text-slate-800 mb-2') { t('weekly_summaries.show.top_expense') }
        div(class: 'flex items-center justify-between') do
          span(class: 'flex items-center gap-2 text-sm text-slate-700') do
            span(class: 'w-6 h-6 rounded flex items-center justify-center',
                 style: "background: #{color}20; color: #{color}") do
              render category_icon(top_category.key).new(class: 'w-[13px] h-[13px]')
            end
            plain I18n.t("activerecord.attributes.expense.categories.#{top_category.key}")
          end
          span(class: 'text-sm font-semibold text-slate-800') { format_currency(top_category.amount) }
        end
      end
    end

    def cta
      link_to(helpers.analysis_path(year: @summary.week.first.year, month: @summary.week.first.month),
              class: 'w-full bg-blue-600 text-white rounded-xl py-3 text-sm font-semibold ' \
                     'flex items-center justify-center gap-2') do
        plain t('weekly_summaries.show.cta')
        render PhlexIcons::Lucide::ArrowRight.new(class: 'w-[15px] h-[15px]')
      end
    end

    def range_text
      first = @summary.week.first
      last = @summary.week.last

      if first.year != last.year
        t('weekly_summaries.show.range.cross_year', start_day: first.day, start_month: month_name(first.month),
                                                      start_year: first.year, end_day: last.day,
                                                      end_month: month_name(last.month), end_year: last.year)
      elsif first.month != last.month
        t('weekly_summaries.show.range.cross_month', start_day: first.day, start_month: month_name(first.month),
                                                       end_day: last.day, end_month: month_name(last.month))
      else
        t('weekly_summaries.show.range.same_month', start_day: first.day, end_day: last.day,
                                                      month: month_name(first.month))
      end
    end

    def month_name(month) = I18n.t('date.month_names')[month]
  end
end
