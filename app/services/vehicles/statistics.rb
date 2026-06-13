module Vehicles
  class Statistics
    def initialize(vehicle:, date: Date.current)
      @vehicle = vehicle
      @date = date
    end

    def km_this_month
      first = @vehicle.refuelings
                      .where(date: @date.beginning_of_month..@date.end_of_month)
                      .order(:date, :created_at)
                      .first
      return 0 unless first

      [@vehicle.odometer_km - first.odometer_km, 0].max
    end
  end
end
