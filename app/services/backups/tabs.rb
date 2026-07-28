module Backups
  module Tabs
    class UnknownTab < StandardError; end

    Format = Data.define(:type, :pattern)

    CURRENCY = Format.new(type: 'CURRENCY', pattern: '"R$" #,##0.00')
    UNIT_PRICE = Format.new(type: 'CURRENCY', pattern: '"R$" #,##0.000')
    DECIMAL = Format.new(type: 'NUMBER', pattern: '#,##0.000')
    INTEGER = Format.new(type: 'NUMBER', pattern: '#,##0')
    DATE = Format.new(type: 'DATE', pattern: 'dd/mm/yyyy')
    DATE_TIME = Format.new(type: 'DATE_TIME', pattern: 'dd/mm/yyyy hh:mm')

    Column = Data.define(:name, :format)

    Tab = Data.define(:key, :columns) do
      def title
        I18n.t("backups.tabs.#{key}.title")
      end

      def headers
        columns.map { |column| I18n.t("backups.tabs.#{key}.columns.#{column.name}") }
      end

      def width
        columns.size
      end
    end

    def self.column(name, format = nil)
      Column.new(name: name, format: format)
    end

    ALL = [
      Tab.new(key: :summary, columns: [
        column(:month),
        column(:earnings, CURRENCY),
        column(:expenses, CURRENCY),
        column(:profit, CURRENCY),
        column(:savings, CURRENCY)
      ]),
      Tab.new(key: :earnings, columns: [
        column(:date, DATE),
        column(:platform),
        column(:amount, CURRENCY),
        column(:trips_count, INTEGER),
        column(:notes),
        column(:created_at, DATE_TIME)
      ]),
      Tab.new(key: :expenses, columns: [
        column(:date, DATE),
        column(:category),
        column(:amount, CURRENCY),
        column(:vendor),
        column(:description),
        column(:paid),
        column(:installment_number, INTEGER),
        column(:installment_count, INTEGER)
      ]),
      Tab.new(key: :refuelings, columns: [
        column(:date, DATE),
        column(:vendor),
        column(:liters, DECIMAL),
        column(:price_per_liter, UNIT_PRICE),
        column(:total_amount, CURRENCY),
        column(:odometer_km, INTEGER),
        column(:full_tank)
      ]),
      Tab.new(key: :maintenances, columns: [
        column(:category),
        column(:interval_km, INTEGER),
        column(:last_done_km, INTEGER),
        column(:estimated_cost, CURRENCY)
      ]),
      Tab.new(key: :goals, columns: [
        column(:kind),
        column(:metric),
        column(:period_start, DATE),
        column(:period_end, DATE),
        column(:target_amount, CURRENCY)
      ])
    ].freeze

    def self.find(key)
      ALL.find { |tab| tab.key == key.to_sym } || raise(UnknownTab, "no backup tab for key=#{key}")
    end
  end
end
