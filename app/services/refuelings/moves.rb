module Refuelings
  class Moves
    def self.call(user:) = new(user: user).call

    def initialize(user:)
      @user = user
    end

    def call
      return [] unless vehicle && anchor

      (credits + debits).sort_by { |move| move[:date] }.reverse
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
      vehicle.refuelings.chronological.map do |refueling|
        { kind: :credit, date: refueling.date, amount: refueling.total_amount,
          vendor: refueling.vendor, liters: refueling.liters, price_per_liter: refueling.price_per_liter }
      end
    end

    def debits
      user.expenses.where(category: :fuel).where.missing(:refueling)
        .where('expenses.date >= ?', anchor).chronological.map do |expense|
          { kind: :debit, date: expense.date, amount: -expense.amount, description: expense.description }
        end
    end
  end
end
