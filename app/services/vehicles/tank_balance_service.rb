module Vehicles
  class TankBalanceService
    MOVES_LIMIT = 8
    EMPTY = { balance: 0, full: nil, status_key: :empty, moves: [] }.freeze

    def initialize(user:)
      @user = user
    end

    def call
      vehicle = @user.vehicle
      return EMPTY unless vehicle

      full = last_full_amount(vehicle)
      balance = vehicle.refuelings.sum(:total_amount) - debit_expenses.sum(:amount)

      {
        balance: balance,
        full: full,
        status_key: TankStatus.for(balance, full).key,
        moves: build_moves(vehicle)
      }
    end

    private

    def debit_expenses
      @user.expenses.where(category: :fuel).where.missing(:refueling)
    end

    def last_full_amount(vehicle)
      vehicle.refuelings.full_tank.chronological.first&.total_amount
    end

    def build_moves(vehicle)
      credits = vehicle.refuelings.chronological.map do |refueling|
        { kind: :credit, date: refueling.date, amount: refueling.total_amount,
          vendor: refueling.vendor, liters: refueling.liters, price_per_liter: refueling.price_per_liter }
      end
      debits = debit_expenses.chronological.map do |expense|
        { kind: :debit, date: expense.date, amount: -expense.amount, description: expense.description }
      end

      (credits + debits).sort_by { |move| move[:date] }.reverse.first(MOVES_LIMIT)
    end
  end
end
