require 'csv'

module Exports
  module Generators
    class Csv
      include Labels

      File = Data.define(:io, :filename, :content_type)

      EARNING_COLUMNS = %w[date platform amount trips_count notes].freeze
      EXPENSE_COLUMNS = %w[date category vendor amount paid description].freeze
      REFUELING_COLUMNS = %w[date vendor liters price_per_liter total_amount odometer_km].freeze
      MAINTENANCE_COLUMNS = %w[category interval_km last_done_km estimated_cost].freeze
      FORMULA_PREFIXES = ['=', '+', '-', '@', "\t", "\r"].freeze

      def self.call(payload:)
        new(payload: payload).call
      end

      def initialize(payload:)
        @payload = payload
      end

      def call
        io = StringIO.new
        write_section(io, I18n.t('exports.report.sections.earnings'), EARNING_COLUMNS, earning_rows)
        write_section(io, I18n.t('exports.report.sections.expenses'), EXPENSE_COLUMNS, expense_rows)
        write_section(io, I18n.t('exports.report.sections.refuelings'), REFUELING_COLUMNS, @payload.refuelings)
        write_section(io, I18n.t('exports.report.sections.maintenances'), MAINTENANCE_COLUMNS, maintenance_rows)
        io.rewind

        File.new(io: io, filename: "drivecash-export-#{Time.current.to_i}.csv", content_type: 'text/csv')
      end

      private

      def earning_rows
        @payload.earnings.map { |row| row.merge(platform: platform_label(row[:platform])) }
      end

      def expense_rows
        @payload.expenses.map { |row| row.merge(category: expense_category_label(row[:category])) }
      end

      def maintenance_rows
        @payload.maintenances.map { |row| row.merge(category: maintenance_category_label(row[:category])) }
      end

      def write_section(io, label, columns, rows)
        return if rows.empty?

        io.puts "# #{label}"
        csv_writer = CSV.new(io)
        csv_writer << columns
        rows.each { |row| csv_writer << columns.map { |col| format_value(row[col.to_sym]) } }
        io.puts
      end

      def format_value(value)
        case value
        when BigDecimal then format('%.2f', value)
        when Date then value.iso8601
        when String then sanitize_formula(value)
        else value
        end
      end

      def sanitize_formula(value)
        return value unless FORMULA_PREFIXES.include?(value[0])

        "'#{value}"
      end
    end
  end
end
