module Vehicles
  class TankStatus
    def self.for(balance, full)
      ratio = full.to_f.positive? ? balance.to_f / full.to_f : 0
      return :negative if balance.negative?
      return :empty if balance.zero?
      return :low if ratio <= 0.25

      :ok
    end
  end
end
