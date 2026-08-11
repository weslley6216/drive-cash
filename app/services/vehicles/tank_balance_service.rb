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

      refuelings = vehicle.refuelings.chronological.to_a
      return EMPTY if refuelings.empty?

      anchor = refuelings.map(&:date).min
      last_fill = refuelings.find(&:full_tank)
      full = last_fill&.total_amount
      debit_expenses = debit_expenses_since(anchor).chronological.to_a
      balance = compute_balance(refuelings, debit_expenses)

      {
        balance:    balance,
        full:       full,
        status_key: TankStatus.for(balance, full),
        last_fill:  last_fill,
        moves:      build_moves(refuelings, debit_expenses)
      }
    end

    private

    def compute_balance(refuelings, debit_expenses)
      credits = refuelings.sum(&:total_amount)
      debits = debit_expenses.sum(&:amount)
      credits - debits
    end

    def debit_expenses_since(anchor)
      @user.expenses.where(category: :fuel).where.missing(:refueling).where('expenses.date >= ?', anchor)
    end

    def build_moves(refuelings, debit_expenses)
      credits = refuelings.map do |refueling|
        { kind: :credit, date: refueling.date, amount: refueling.total_amount,
          vendor: refueling.vendor, liters: refueling.liters, price_per_liter: refueling.price_per_liter }
      end
      debits = debit_expenses.map do |expense|
        { kind: :debit, date: expense.date, amount: -expense.amount, description: expense.description }
      end

      (credits + debits).sort_by { |move| move[:date] }.reverse.first(MOVES_LIMIT)
    end
  end
end
