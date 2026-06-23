module Chat
  class MaintenanceUpdater
    def persist(payload, user:)
      vehicle = user.vehicle
      return PersistedResult.failure(errors: [I18n.t('chat.errors.no_vehicle')]) unless vehicle

      maintenance = vehicle.maintenances.find_by(category: payload['category'])
      return PersistedResult.failure(errors: [I18n.t('chat.errors.maintenance_not_found')]) unless maintenance

      done_km = payload['done_km']&.to_i || vehicle.odometer_km

      if maintenance.update(last_done_km: done_km)
        PersistedResult.success(record: maintenance, action: 'update_maintenance')
      else
        PersistedResult.failure(errors: maintenance.errors.full_messages)
      end
    end
  end
end
