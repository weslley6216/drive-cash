module Calendars
  class Week < Data.define(:monday)
    def self.containing(date)
      new(monday: date)
    end

    def self.parse(iso_date)
      return nil if iso_date.to_s.length > 128

      containing(Date.iso8601(iso_date.to_s))
    rescue Date::Error
      nil
    end

    def initialize(monday:)
      super(monday: monday.beginning_of_week)
    end

    def range
      monday..monday.end_of_week
    end

    def previous
      self.class.containing(monday - 7)
    end

    def next
      self.class.containing(monday + 7)
    end

    def current?
      range.cover?(Date.current)
    end

    def future?
      monday > Date.current
    end

    def to_param
      monday.iso8601
    end
  end
end
