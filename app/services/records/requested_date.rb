module Records
  class RequestedDate
    def self.call(raw, today: Date.current)
      date = Date.iso8601(raw)
      date <= today ? date : today
    rescue Date::Error, TypeError
      today
    end
  end
end
