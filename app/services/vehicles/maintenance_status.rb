module Vehicles
  class MaintenanceStatus
    Status = Data.define(:key, :color, :badge_class, :tint_class)

    OVERDUE = Status.new(:overdue, '#dc2626', 'text-red-700 bg-red-100 border-red-200', 'border-red-200 bg-red-50/60')
    DUE_SOON = Status.new(:soon, '#f59e0b', 'text-amber-700 bg-amber-100 border-amber-200', 'border-amber-200 bg-amber-50/50')
    ON_TRACK = Status.new(:ok, '#10b981', 'text-slate-500 bg-slate-100 border-slate-200', '')

    def self.for(progress)
      return OVERDUE if progress >= 100
      return DUE_SOON if progress >= 80

      ON_TRACK
    end
  end
end
