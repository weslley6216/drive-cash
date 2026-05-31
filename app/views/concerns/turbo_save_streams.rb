module TurboSaveStreams
  private

  def stats_grid_stream(totals:, month:, year:)
    raw turbo_stream.replace('stats_grid') {
      render StatsGridComponent.new(totals: totals, month: month, year: year)
    }
  end

  def hero_stream(totals:, year:, month:)
    monthly_view = month.present?
    raw turbo_stream.update('hero_profit_card') {
      render HeroProfitCardComponent.new(
        profit: totals[:profit],
        change_percent: totals[:change_percent],
        profit_per_day: totals[:profit_per_day],
        days_count: totals[:days],
        monthly_series: monthly_view ? totals[:daily_profit_series] : totals[:monthly_profit_series],
        year: year,
        month: month,
        daily_mode: monthly_view
      )
    }
  end

  def today_card_stream
    today = Dashboard::TodayService.new.call
    raw turbo_stream.update('today_card') {
      render TodayCardComponent.new(**today) if today
    }
  end

  def recent_activity_stream(year:, month:)
    rows = Dashboard::RecentActivityService.new(year: year, month: month).call
    raw turbo_stream.update('recent_activity') {
      render RecentActivityComponent.new(rows: rows)
    }
  end

  def category_breakdown_stream(year:, month:)
    categories = Dashboard::CategoryBreakdownService.new(year: year, month: month).call
    raw turbo_stream.update('category_breakdown') {
      render CategoryBreakdownComponent.new(categories: categories)
    }
  end

  def flash_stream(target = 'flash', inline: false)
    raw turbo_stream.update(target) {
      render FlashComponent.new(flash: helpers.flash, inline: inline)
    }
  end

  def modal_stream(view)
    raw turbo_stream.replace('modal') { render view }
  end

  def clear_modal_stream
    raw turbo_stream.update('modal', '')
  end
end
