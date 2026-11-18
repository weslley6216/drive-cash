module History
  class FeedService
    PER_PAGE = 50

    def initialize(year: Date.current.year, month: nil, query: nil, slice: Slice.new, focus_day: nil, page: 1, user: Current.user)
      @year = year
      @month = month
      @query = query
      @slice = slice
      @focus_day = focus_day
      @page = page
      @user = user
    end

    def call
      items = paged_items
      grouped = items.group_by(&:date).sort_by { |date, _| date }.reverse
      groups = grouped.map { |date, day_items| build_group(date, day_items) }

      {
        groups:      with_focus_gap(groups),
        summary:     build_summary,
        total_count: total_count,
        next_page:   next_page(items.size)
      }
    end

    private

    attr_reader :year, :month, :query, :slice, :focus_day, :page

    def paged_items
      requested = page * PER_PAGE
      combined = combined_items(requested)
      return combined if combined.size < requested

      complete_last_day(combined)
    end

    def combined_items(cap)
      earnings = include_earnings? ? filtered_earnings.chronological.limit(cap).to_a : []
      expenses = include_expenses? ? filtered_expenses.chronological.limit(cap).to_a : []

      (earnings + expenses)
        .sort_by { |record| [record.date, record.created_at] }
        .reverse
        .first(cap)
    end

    def complete_last_day(items)
      boundary_date = items.last.date
      extra_earnings = include_earnings? ? filtered_earnings.where(date: boundary_date).to_a : []
      extra_expenses = include_expenses? ? filtered_expenses.where(date: boundary_date).to_a : []

      (items + extra_earnings + extra_expenses).uniq
    end

    def total_count
      earnings_count = include_earnings? ? filtered_earnings.count : 0
      expenses_count = include_expenses? ? filtered_expenses.count : 0

      earnings_count + expenses_count
    end

    def next_page(loaded_count)
      page + 1 unless loaded_count >= total_count
    end

    def filtered_earnings
      search.earnings(slice_query.earnings(@user.earnings.in_period(year, month)))
    end

    def filtered_expenses
      search.expenses(slice_query.expenses(@user.expenses.in_period(year, month)))
    end

    def slice_query
      @slice_query ||= SliceQuery.new(slice)
    end

    def search
      @search ||= RecordSearch.new(query)
    end

    def summary_earnings_scope
      @user.earnings.in_period(year, month)
    end

    def summary_expenses_scope
      @user.expenses.in_period(year, month)
    end

    def build_summary
      earnings_total = summary_earnings_scope.sum(:amount)
      expenses_total = summary_expenses_scope.sum(:amount)
      paid_expenses_total = @user.expenses.paid_in_period(year, month).sum(:amount)

      {
        earnings: earnings_total,
        expenses: expenses_total,
        net:      earnings_total - paid_expenses_total
      }
    end

    def include_earnings?
      slice.include_earnings?
    end

    def include_expenses?
      slice.include_expenses?
    end

    def build_group(date, day_items)
      day_earnings = day_items.select(&:credit?).sum(&:amount)
      day_expenses = day_items.reject(&:credit?).sum(&:amount)

      {
        date:           date,
        items:          day_items.sort_by(&:created_at).reverse,
        earnings_total: day_earnings,
        expenses_total: day_expenses
      }
    end

    def with_focus_gap(groups)
      return groups if focus_day.nil? || day_logged?

      (groups + [{ date: focus_day, items: [], gap: true }]).sort_by { |group| group[:date] }.reverse
    end

    def day_logged?
      @user.earnings.exists?(date: focus_day) || @user.expenses.exists?(date: focus_day)
    end
  end
end
