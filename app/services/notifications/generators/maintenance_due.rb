module Notifications
  module Generators
    class MaintenanceDue
      def initialize(context)
        @context = context
      end

      def call
        vehicle = @context.user.vehicle
        return [] unless vehicle

        vehicle.maintenances.filter_map { |maintenance| payload_for(maintenance) }
      end

      private

      def payload_for(maintenance)
        status = Vehicles::MaintenanceStatus.for(maintenance.progress)
        return nil if status == :ok

        {
          kind:  'maintenance_due',
          data:  {
            'maintenance_id' => maintenance.id,
            'status'         => status.to_s,
            'category'       => maintenance.category,
            'km_until'       => maintenance.km_until,
            'interval_km'    => maintenance.interval_km
          },
          dedup: { 'maintenance_id' => maintenance.id, 'status' => status.to_s }
        }
      end
    end
  end
end
