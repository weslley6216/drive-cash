module Refuelings
  class RecentVendors
    LIMIT = 4

    def self.call(vehicle:)
      new(vehicle: vehicle).call
    end

    def initialize(vehicle:)
      @vehicle = vehicle
    end

    def call
      @vehicle.refuelings.chronological.where.not(vendor: [nil, '']).pluck(:vendor).uniq.first(LIMIT)
    end
  end
end
