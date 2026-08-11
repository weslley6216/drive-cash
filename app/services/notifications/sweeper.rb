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
      @payloads ||= begin
        context = Context.new(user: @user, date: @date)
        Registry::GENERATORS.flat_map { |generator| generator.new(context).call }
      end
    end

    def already_notified?(payload)
      existing_data_by_kind[payload[:kind]].to_a.any? { |data| dedup_match?(data, payload[:dedup]) }
    end

    def existing_data_by_kind
      @existing_data_by_kind ||= @user.notifications
        .where(kind: payloads.map { |payload| payload[:kind] })
        .pluck(:kind, :data)
        .group_by(&:first)
        .transform_values { |pairs| pairs.map(&:last) }
    end

    def dedup_match?(data, dedup)
      dedup.all? { |key, value| data[key.to_s] == value }
    end
  end
end
