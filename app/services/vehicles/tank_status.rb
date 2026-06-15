module Vehicles
  class TankStatus
    def self.for(balance, full)
      return :negative if balance.negative?
      return :empty if balance.zero?

      ratio = full.to_f.positive? ? balance.to_f / full.to_f : 0
      return :ok if ratio >= 0.75
      return :mid if ratio >= 0.50
      return :low if ratio >= 0.25

      :critical
    end
  end
end
