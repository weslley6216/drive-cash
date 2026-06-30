require 'csv'

module Exports
  module Generators
    class Csv
      File = Data.define(:io, :filename, :content_type)

      EARNING_COLUMNS = %w[date platform amount trips_count notes].freeze
      EXPENSE_COLUMNS = %w[date category vendor amount paid description].freeze
      REFUELING_COLUMNS = %w[date vendor liters price_per_liter total_amount odometer_km].freeze
      MAINTENANCE_COLUMNS = %w[category interval_km last_done_km estimated_cost].freeze

      def self.call(payload:)
        new(payload: payload).call
      end

      def initialize(payload:)
        @payload = payload
      end

      def call
        io = StringIO.new
        write_section(io, 'Receitas', EARNING_COLUMNS, @payload.earnings)
        write_section(io, 'Despesas', EXPENSE_COLUMNS, @payload.expenses)
        write_section(io, 'Abastecimentos', REFUELING_COLUMNS, @payload.refuelings)
        write_section(io, 'Manutenções', MAINTENANCE_COLUMNS, @payload.maintenances)
        io.rewind

        File.new(io: io, filename: "drivecash-export-#{Time.current.to_i}.csv", content_type: 'text/csv')
      end

      private

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
        else value
        end
      end
    end
  end
end
