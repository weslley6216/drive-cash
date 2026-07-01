module Exports
  class PeriodRange
    PERIODS = {
      'this_month' => ->(today) { today.beginning_of_month..today.end_of_month },
      'last_month' => ->(today) { (today << 1).beginning_of_month..(today << 1).end_of_month },
      'year'       => ->(today) { today.beginning_of_year..today.end_of_year }
    }.freeze

    def initialize(kind:, today: Date.current, custom_start: nil, custom_end: nil)
      @kind = kind.to_s
      @today = today
      @custom_start = custom_start
      @custom_end = custom_end
    end

    def period_start
      range.first
    end

    def period_end
      range.last
    end

    private

    def range
      @range ||= @kind == 'custom' ? (@custom_start..@custom_end) : PERIODS.fetch(@kind).call(@today)
    end
  end
end
