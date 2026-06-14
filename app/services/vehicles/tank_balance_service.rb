module Vehicles
  class TankBalanceService
    MOVES_LIMIT = 8
    EMPTY = { balance: 0, full: nil, status_key: :empty, last_fill: nil, moves: [] }.freeze

    def initialize(user:)
      @user = user
    end

    def call
      vehicle = @user.vehicle
      return EMPTY unless vehicle

      anchor = vehicle.refuelings.minimum(:date)
      return EMPTY unless anchor

      last_fill = vehicle.refuelings.full_tank.chronological.first
      full = last_fill&.total_amount
      balance = vehicle.refuelings.sum(:total_amount) - debit_expenses_since(anchor).sum(:amount)

      {
        balance:    balance,
        full:       full,
        status_key: TankStatus.for(balance, full),
        last_fill:  last_fill,
        moves:      build_moves(vehicle, anchor)
      }
    end

    private

    def debit_expenses_since(anchor)
      @user.expenses.where(category: :fuel).where.missing(:refueling).where('expenses.date >= ?', anchor)
    end

    def build_moves(vehicle, anchor)
      credits = vehicle.refuelings.chronological.map do |refueling|
        { kind: :credit, date: refueling.date, amount: refueling.total_amount,
          vendor: refueling.vendor, liters: refueling.liters, price_per_liter: refueling.price_per_liter }
      end
      debits = debit_expenses_since(anchor).chronological.map do |expense|
        { kind: :debit, date: expense.date, amount: -expense.amount, description: expense.description }
      end

      (credits + debits).sort_by { |move| move[:date] }.reverse.first(MOVES_LIMIT)
    end
  end
end
