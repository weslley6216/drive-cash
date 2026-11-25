module Refuelings
  class TankCycles
    Cycle = Data.define(:opener, :moves, :closing_balance, :current, :km_per_liter)

    def self.call(moves:) = new(moves: moves).call

    def initialize(moves:)
      @moves = moves
    end

    def call
      return [] if @moves.empty?

      build_cycles(group_into_cycles(with_running_balance))
    end

    private

    def with_running_balance
      balance = BigDecimal('0')

      @moves.reverse.map do |move|
        balance += move[:amount]
        move.merge(balance_after: balance)
      end
    end

    def group_into_cycles(moves_ascending)
      groups = []

      moves_ascending.each do |move|
        starts_new_cycle = groups.empty? || (move[:kind] == :credit && move[:full_tank])
        groups << [] if starts_new_cycle
        groups.last << move
      end

      groups
    end

    def build_cycles(groups_ascending)
      groups_ascending.each_with_index.map do |group, index|
        current = index == groups_ascending.size - 1
        next_opener = groups_ascending[index + 1]&.first

        Cycle.new(
          opener:          group.first,
          moves:           group.reverse,
          closing_balance: group.last[:balance_after],
          current:         current,
          km_per_liter:    km_per_liter_for(opener: group.first, next_opener: next_opener, current: current)
        )
      end.reverse
    end

    def km_per_liter_for(opener:, next_opener:, current:)
      return nil if current || next_opener.nil? || !opener[:full_tank]

      KmPerLiter.call(from_km: opener[:odometer_km], to_km: next_opener[:odometer_km], liters: next_opener[:liters])
    end
  end
end
