module Backups
  class Summary
    Result = Data.define(:rows, :month_count)

    def initialize(earnings:, expenses:, savings_percentage:)
      @earnings = earnings
      @expenses = expenses
      @savings_percentage = savings_percentage
    end

    def call
      month_rows = months.map { |month| month_row(month) }

      Result.new(rows: month_rows + total_rows(month_rows), month_count: month_rows.size)
    end

    private

    def months
      (@earnings + @expenses).map { |entry| entry.date.strftime('%Y-%m') }.uniq.sort
    end

    def month_row(month)
      earnings = sum_for(@earnings, month)
      expenses = sum_for(@expenses, month)
      profit = round(earnings - expenses)

      [month, earnings, expenses, profit, savings_for(profit)]
    end

    def sum_for(entries, month)
      round(entries.select { |entry| entry.date.strftime('%Y-%m') == month }.sum(&:amount))
    end

    def savings_for(profit)
      round([profit * @savings_percentage / 100.0, 0].max)
    end

    def total_rows(month_rows)
      month_rows.group_by { |row| row.first[0, 4] }.map do |year, rows|
        [
          I18n.t('backups.summary.total', year: year),
          round(rows.sum { |row| row[1] }),
          round(rows.sum { |row| row[2] }),
          round(rows.sum { |row| row[3] }),
          round(rows.sum { |row| row[4] })
        ]
      end
    end

    def round(value)
      value.to_f.round(2)
    end
  end
end
