module Vehicles
  class TankCadence
    EMPTY = { average_days: nil }.freeze

    def initialize(user:)
      @user = user
    end

    def call
      vehicle = @user.vehicle
      return EMPTY unless vehicle

      dates = vehicle.refuelings.full_tank.order(date: :asc).pluck(:date)
      return EMPTY if dates.size < 2

      gaps = dates.each_cons(2).map { |first, second| (second - first).to_i }
      { average_days: (gaps.sum.to_f / gaps.size).round }
    end
  end
end
