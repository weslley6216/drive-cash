module History
  class MonthlyBreakdown
    def initialize(window:, totals:)
      @window = window
      @totals = totals
    end

    def call
      months = build_months
      shift = LevelShift.new(months).call

      { months: months, total: total(months), average: average(months), shift: shift,
        highlighted: highlighted(months, shift), rows: rows(months, shift) }
    end

    private

    def build_months
      @window.map do |year, month|
        entry = @totals[[year, month]]
        { year: year, month: month, total: entry&.dig(:total) || 0, count: entry&.dig(:count) || 0 }
      end
    end

    def total(months)
      months.sum { |month| month[:total] }.round(2)
    end

    def average(months)
      first_logged = months.index { |month| month[:count] > 0 }
      return 0 if first_logged.nil?

      (total(months) / (months.size - first_logged)).round(2)
    end

    def highlighted(months, shift)
      return [months.size - 1] if shift.nil?

      shift_index = months.index { |month| month[:year] == shift[:year] && month[:month] == shift[:month] }
      (shift_index..months.size - 1).to_a
    end

    def rows(months, shift)
      logged = months.each_index.select { |index| months[index][:count] > 0 }.reverse

      logged.map.with_index { |index, position| build_row(months[index], previous_row(months, logged, position), shift) }
    end

    def previous_row(months, logged, position)
      previous_index = logged[position + 1]
      months[previous_index] if previous_index
    end

    def build_row(month, previous, shift)
      change = previous && Dashboard::PercentChange.between(month[:total], previous[:total])

      {
        year: month[:year], month: month[:month], total: month[:total], count: month[:count],
        previous_month: previous&.dig(:month), change: change,
        equal: previous ? (month[:total] - previous[:total]).abs < 0.005 : false,
        shift: shift.present? && month[:year] == shift[:year] && month[:month] == shift[:month]
      }
    end
  end
end
