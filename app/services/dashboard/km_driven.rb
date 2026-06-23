module Dashboard
  class KmDriven
    def initialize(user:, year:, month: nil)
      @user = user
      @year = year
      @month = month
    end

    def call
      return nil if scope.count < 2

      delta = scope.maximum(:odometer_km).to_i - scope.minimum(:odometer_km).to_i
      delta.positive? ? delta : nil
    end

    private

    def scope
      vehicle = @user.vehicle
      return Refueling.none unless vehicle

      vehicle.refuelings.where.not(odometer_km: nil).where(date: date_range)
    end

    def date_range
      if @month
        start = Date.new(@year, @month, 1)
        start..start.end_of_month
      else
        Date.new(@year, 1, 1)..Date.new(@year, 12, 31)
      end
    end
  end
end
