module Refuelings
  class Moves
    def self.call(user:) = new(user: user).call

    def initialize(user:)
      @user = user
    end

    def call
      return [] unless vehicle && anchor

      (credits + debits).sort_by.with_index { |move, position| [move[:date], move[:kind] == :credit ? 0 : 1, position] }.reverse
    end

    private

    attr_reader :user

    def vehicle
      @vehicle ||= user.vehicle
    end

    def anchor
      @anchor ||= vehicle.refuelings.minimum(:date)
    end

    def credits
      vehicle.refuelings.order(:date, :created_at).map do |refueling|
        { kind: :credit, date: refueling.date, amount: refueling.total_amount,
          vendor: refueling.vendor, liters: refueling.liters, price_per_liter: refueling.price_per_liter,
          full_tank: refueling.full_tank, odometer_km: refueling.odometer_km }
      end
    end

    def debits
      user.expenses.where(category: :fuel).where.missing(:refueling)
        .where('expenses.date >= ?', anchor).order(:date, :created_at).map do |expense|
          { kind: :debit, date: expense.date, amount: -expense.amount, description: expense.description }
        end
    end
  end
end
