module Dashboard
  class KmDriven
    def initialize(user:, year: nil, month: nil, range: nil)
      @user = user
      @year = year
      @month = month
      @range = range
    end

    def call
      count, max_km, min_km = scope.pick(Arel.sql('COUNT(*), MAX(odometer_km), MIN(odometer_km)'))
      delta(count, max_km, min_km)
    end

    def monthly
      scope.group(Arel.sql('EXTRACT(MONTH FROM date)::int'))
        .pluck(Arel.sql('EXTRACT(MONTH FROM date)::int, COUNT(*), MAX(odometer_km), MIN(odometer_km)'))
        .to_h { |month, *readings| [month, delta(*readings)] }
        .compact
    end

    private

    def delta(count, max_km, min_km)
      return nil if count.to_i < 2

      difference = max_km.to_i - min_km.to_i
      difference.positive? ? difference : nil
    end

    def scope
      vehicle = @user.vehicle
      return Refueling.none unless vehicle

      vehicle.refuelings.where.not(odometer_km: nil).where(date: date_range)
    end

    def date_range
      @range || period_range
    end

    def period_range
      if @month
        start = Date.new(@year, @month, 1)
        start..start.end_of_month
      else
        Date.new(@year, 1, 1)..Date.new(@year, 12, 31)
      end
    end
  end
end
