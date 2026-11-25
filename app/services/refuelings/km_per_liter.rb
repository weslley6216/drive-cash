module Refuelings
  class KmPerLiter
    def self.call(from_km:, to_km:, liters:)
      return nil if from_km.nil? || to_km.nil?

      distance_km = to_km - from_km
      return nil if distance_km <= 0

      return nil if liters.nil?

      liters_value = liters.to_d
      return nil if liters_value.zero?

      distance_km / liters_value
    end
  end
end
