module Chat
  class MaintenanceUpdater
    def persist(payload, user:)
      vehicle = user.vehicle
      return PersistedResult.failure(errors: [I18n.t('chat.errors.no_vehicle')]) unless vehicle

      maintenance = vehicle.maintenances.find_by(category: payload['category'])
      return PersistedResult.failure(errors: [I18n.t('chat.errors.maintenance_not_found')]) unless maintenance

      request = Maintenances::MarkDoneRequest.new(maintenance: maintenance, done_km: payload['done_km']&.to_i, companion_ids: [])
      result = Maintenances::MarkDone.call(request: request)

      if result.success?
        PersistedResult.success(record: maintenance.reload, action: 'update_maintenance')
      else
        PersistedResult.failure(errors: result.request.errors[:done_km])
      end
    end
  end
end
