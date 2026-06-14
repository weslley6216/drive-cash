module Dashboard
  class PercentChange
    def self.between(current, previous)
      current_float = current.to_f
      previous_float = previous.to_f
      return nil if previous_float.zero?

      ((current_float - previous_float) / previous_float.abs * 100).round(1)
    end
  end
end
