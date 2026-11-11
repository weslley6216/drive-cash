module Maintenances
  class UndoMarkDone
    def self.call(vehicle:, restore:)
      new(vehicle: vehicle, restore: restore).call
    end

    def initialize(vehicle:, restore:)
      @vehicle = vehicle
      @restore = restore.stringify_keys
    end

    def call
      Maintenance.transaction do
        targets.each { |maintenance| maintenance.update!(last_done_km: @restore.fetch(maintenance.id.to_s)) }
      end
      true
    rescue ActiveRecord::RecordInvalid
      false
    end

    private

    def targets
      @vehicle.maintenances.where(id: @restore.keys)
    end
  end
end
