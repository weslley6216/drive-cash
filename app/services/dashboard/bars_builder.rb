module Dashboard
  class BarsBuilder
    def initialize(user:, year:, month:)
      @user = user
      @year = year
      @month = month
    end

    def call
      @month ? daily_bars : annual_bars
    end

    private

    def annual_bars
      earnings_by = @user.earnings.in_period(@year)
        .group(Arel.sql('EXTRACT(MONTH FROM date)::int'))
        .sum(:amount)
      expenses_by = @user.expenses.paid_in_period(@year)
        .group(Arel.sql('EXTRACT(MONTH FROM date)::int'))
        .sum(:amount)

      return [] if earnings_by.empty? && expenses_by.empty?

      (1..12).map do |month_number|
        {
          unit:     :month,
          key:      month_number,
          label:    I18n.t('date.abbr_month_names')[month_number].capitalize,
          earnings: earnings_by[month_number].to_f,
          expenses: expenses_by[month_number].to_f,
          empty:    earnings_by[month_number].nil? && expenses_by[month_number].nil?
        }
      end
    end

    def daily_bars
      earnings_by = @user.earnings.in_period(@year, @month)
        .group(Arel.sql('EXTRACT(DAY FROM date)::int'))
        .sum(:amount)
      expenses_by = @user.expenses.paid_in_period(@year, @month)
        .group(Arel.sql('EXTRACT(DAY FROM date)::int'))
        .sum(:amount)

      days = (earnings_by.keys + expenses_by.keys).uniq.sort
      days.map do |day|
        {
          unit:     :day,
          key:      day,
          label:    day.to_s,
          earnings: earnings_by[day].to_f,
          expenses: expenses_by[day].to_f,
          empty:    false
        }
      end
    end
  end
end
