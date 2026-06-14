module Dashboard
  class RecentActivityService
    def initialize(year:, month: nil, limit: 5, user: Current.user, date: Date.current)
      @year = year
      @month = month
      @limit = limit
      @user = user
      @date = date
    end

    def call
      merged = (earning_rows + expense_rows)
               .sort_by { |row| [row[:date], row[:created_at]] }
               .reverse
               .first(@limit)

      merged.map { |row| build_row(row) }
    end

    private

    attr_reader :year, :month, :limit

    def earning_rows
      earnings_scope.map do |record|
        { type: :earning, record: record, date: record.date, created_at: record.created_at }
      end
    end

    def expense_rows
      expenses_scope.map do |record|
        { type: :expense, record: record, date: record.date, created_at: record.created_at }
      end
    end

    def earnings_scope
      @user.earnings.in_period(year, month).order(date: :desc, created_at: :desc).limit(limit)
    end

    def expenses_scope
      @user.expenses.paid_in_period(year, month).order(date: :desc, created_at: :desc).limit(limit)
    end

    def build_row(row)
      record = row[:record]
      base = {
        type: row[:type],
        date: record.date,
        date_label: format_date(record.date),
        amount: record.amount.to_f
      }

      row[:type] == :earning ? base.merge(earning_fields(record)) : base.merge(expense_fields(record))
    end

    def earning_fields(record)
      {
        label: I18n.t("activerecord.attributes.earning.platforms.#{record.platform}"),
        description: I18n.t('common.trips', count: record.trips_count)
      }
    end

    def expense_fields(record)
      {
        label: I18n.t("activerecord.attributes.expense.categories.#{record.category}"),
        description: record.vendor.presence || record.description.to_s
      }
    end

    def format_date(date)
      return I18n.t('common.today')     if date == @date
      return I18n.t('common.yesterday') if date == @date - 1

      I18n.l(date, format: :short)
    end
  end
end
