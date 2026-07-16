module Notifications
  class Grouping
    BUCKETS = %i[today week earlier].freeze

    Group = Data.define(:key, :rows)

    def initialize(notifications, date: Date.current)
      @notifications = notifications
      @date = date
    end

    def call
      @notifications.group_by { |notification| bucket_for(notification) }
        .sort_by { |key, _records| BUCKETS.index(key) }
        .map { |key, records| Group.new(key: key, rows: records.map { |record| Presenters.present(record) }) }
    end

    private

    def bucket_for(notification)
      created = notification.created_at.to_date
      return :today if created == @date
      return :week if created >= @date.beginning_of_week

      :earlier
    end
  end
end
