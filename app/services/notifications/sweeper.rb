module Notifications
  class Sweeper
    def initialize(user:, date: Date.current)
      @user = user
      @date = date
    end

    def call
      payloads.reject { |payload| already_notified?(payload) }
        .map { |payload| @user.notifications.create!(kind: payload[:kind], data: payload[:data]) }
    end

    private

    def payloads
      context = Context.new(user: @user, date: @date)
      Registry::GENERATORS.flat_map { |generator| generator.new(context).call }
    end

    def already_notified?(payload)
      @user.notifications
        .where(kind: payload[:kind])
        .where('data @> ?', payload[:dedup].to_json)
        .exists?
    end
  end
end
