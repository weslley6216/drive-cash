module Vehicles
  class TankStatus
    Status = Data.define(:key, :color, :bar_class, :num_class, :chip_class)

    NEGATIVE = Status.new(:negative, '#dc2626', 'bg-red-500', 'text-red-700', 'text-red-700 bg-red-100 border-red-200')
    EMPTY = Status.new(:empty, '#dc2626', 'bg-red-500', 'text-red-700', 'text-red-700 bg-red-100 border-red-200')
    LOW = Status.new(:low, '#f59e0b', 'bg-amber-500', 'text-amber-700', 'text-amber-700 bg-amber-100 border-amber-200')
    OK = Status.new(:ok, '#2563eb', 'bg-blue-500', 'text-slate-900', 'text-blue-700 bg-blue-50 border-blue-200')

    def self.for(balance, full)
      ratio = full.to_f.positive? ? balance.to_f / full.to_f : 0
      return NEGATIVE if balance.negative?
      return EMPTY if balance.zero?
      return LOW if ratio <= 0.25

      OK
    end
  end
end
