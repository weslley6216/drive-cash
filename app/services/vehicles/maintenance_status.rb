module Vehicles
  class MaintenanceStatus
    OVERDUE_THRESHOLD = 100
    SOON_THRESHOLD = 80

    def self.for(progress)
      return :overdue if progress >= OVERDUE_THRESHOLD
      return :soon if progress >= SOON_THRESHOLD

      :ok
    end
  end
end
