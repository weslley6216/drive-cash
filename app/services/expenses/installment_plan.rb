module Expenses
  class InstallmentPlan
    attr_reader :series_id, :count

    def initialize(total_amount:, start_date:, period:, repetitions:)
      @total_amount = BigDecimal(total_amount.to_s)
      @start_date = parse_date(start_date)
      @period = period.to_s
      @count = repetitions.to_i
      @series_id = SecureRandom.uuid
    end

    def valid?
      @count >= 2 &&
        Expense::INSTALLMENT_PERIODS.include?(@period) &&
        @total_amount > 0
    end

    def amounts
      @amounts ||= calculate_amounts
    end

    def dates
      @dates ||= calculate_dates
    end

    def installment_attributes(index)
      {
        'amount' => amounts[index],
        'date' => dates[index],
        'paid' => false,
        'installment_series_id' => series_id,
        'installment_number' => index + 1,
        'installment_count' => count
      }
    end

    private

    def calculate_amounts
      cents = (@total_amount * 100).round.to_i
      base = cents / @count
      remainder = cents % @count

      (0...@count).map do |index|
        chunk = base + (index < remainder ? 1 : 0)
        BigDecimal(chunk) / 100
      end
    end

    def calculate_dates
      (0...@count).map { |index| advance_date(@start_date, index) }
    end

    def advance_date(start, index)
      case @period
      when 'weekly' then start + index.weeks
      when 'biweekly' then start + (2 * index).weeks
      when 'monthly' then start >> index
      when 'annual' then start >> (12 * index)
      end
    end

    def parse_date(date_param)
      return date_param.to_date if date_param.respond_to?(:to_date)

      Date.parse(date_param.to_s)
    end
  end
end
