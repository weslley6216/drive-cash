module Exports
  class Builder
    Payload = Data.define(:earnings, :expenses, :refuelings, :maintenances, :totals)
    EMPTY_SECTIONS = { earnings: [], expenses: [], refuelings: [], maintenances: [] }.freeze

    def self.call(export:)
      new(export: export).call
    end

    def initialize(export:)
      @export = export
      @user = export.user
      @range = export.period_start..export.period_end
    end

    def call
      sections = blank_range? ? EMPTY_SECTIONS : collect_sections
      Payload.new(**sections, totals: totals(sections))
    end

    private

    def blank_range?
      @export.period_start.blank? || @export.period_end.blank?
    end

    def collect_sections
      {
        earnings:     collect_earnings,
        expenses:     collect_expenses,
        refuelings:   collect_refuelings,
        maintenances: collect_maintenances
      }
    end

    def collect_earnings
      return [] unless @export.includes_for(:earnings)

      @user.earnings.where(date: @range).order(:date).map do |earning|
        { date: earning.date, amount: earning.amount, platform: earning.platform, trips_count: earning.trips_count, notes: earning.notes }
      end
    end

    def collect_expenses
      return [] unless @export.includes_for(:expenses)

      @user.expenses.where(date: @range).order(:date).map do |expense|
        { date: expense.date, amount: expense.amount, category: expense.category, vendor: expense.vendor, description: expense.description, paid: expense.paid }
      end
    end

    def collect_refuelings
      return [] unless @export.includes_for(:refuelings)
      return [] unless @user.vehicle

      @user.vehicle.refuelings.where(date: @range).order(:date).map do |refueling|
        { date: refueling.date, vendor: refueling.vendor, liters: refueling.liters, price_per_liter: refueling.price_per_liter, total_amount: refueling.total_amount, odometer_km: refueling.odometer_km }
      end
    end

    def collect_maintenances
      return [] unless @export.includes_for(:maintenances)
      return [] unless @user.vehicle

      @user.vehicle.maintenances.order(:category).map do |maintenance|
        { category: maintenance.category, interval_km: maintenance.interval_km, last_done_km: maintenance.last_done_km, estimated_cost: maintenance.estimated_cost }
      end
    end

    def totals(sections)
      earnings_sum = sections[:earnings].sum { |row| row[:amount] || 0 }
      expenses_sum = sections[:expenses].select { |row| row[:paid] }.sum { |row| row[:amount] || 0 }
      count = sections.values.sum(&:size)

      { earnings: earnings_sum, expenses: expenses_sum, profit: earnings_sum - expenses_sum, count: count }
    end
  end
end
