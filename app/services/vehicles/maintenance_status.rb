module Vehicles
  class MaintenanceStatus
    def self.for(progress)
      return :overdue if progress >= 100
      return :soon if progress >= 80

      :ok
    end
  end
end
