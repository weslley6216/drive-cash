module Maintenances
  class MarkDone
    def self.call(request:)
      new(request: request).call
    end

    def initialize(request:)
      @request = request
    end

    def call
      return Result.new(success?: false, request: @request, previous_km: {}) unless @request.valid?

      previous_km = capture_previous_km

      Maintenance.transaction do
        Vehicles::OdometerSync.new(vehicle: maintenance.vehicle, reading_km: @request.done_km, on: @request.done_on).call
        @request.targets.each { |target| target.update!(last_done_km: @request.done_km) }
        mark_notifications_read
      end

      Result.new(success?: true, request: @request, previous_km: previous_km)
    end

    private

    def maintenance = @request.maintenance

    def capture_previous_km
      @request.targets.each_with_object({}) { |target, hash| hash[target.id.to_s] = target.last_done_km }
    end

    def mark_notifications_read
      ids = @request.targets.map(&:id).map(&:to_s)
      maintenance.vehicle.user.notifications.unread
        .where(kind: 'maintenance_due')
        .where("data->>'maintenance_id' IN (?)", ids)
        .mark_all_read!
    end
  end
end
