module WeekRangeLabel
  def week_range_text(week, with_year: false)
    first = week.monday
    last = week.range.last

    if first.year != last.year
      cross_year_text(first, last)
    elsif first.month != last.month
      cross_month_text(first, last, with_year: with_year)
    else
      same_month_text(first, last, with_year: with_year)
    end
  end

  private

  def same_month_text(first, last, with_year:)
    key = with_year ? 'week_range.same_month_with_year' : 'week_range.same_month'
    options = { start_day: first.day, end_day: last.day, month: week_range_month_name(first.month) }
    options[:year] = first.year if with_year

    I18n.t(key, **options)
  end

  def cross_month_text(first, last, with_year:)
    key = with_year ? 'week_range.cross_month_with_year' : 'week_range.cross_month'
    options = { start_day: first.day, start_month: week_range_month_name(first.month), end_day: last.day,
                end_month: week_range_month_name(last.month) }
    options[:year] = last.year if with_year

    I18n.t(key, **options)
  end

  def cross_year_text(first, last)
    I18n.t('week_range.cross_year', start_day: first.day, start_month: week_range_month_name(first.month),
                                      start_year: first.year, end_day: last.day,
                                      end_month: week_range_month_name(last.month), end_year: last.year)
  end

  def week_range_month_name(month) = I18n.t('date.month_names')[month]
end
