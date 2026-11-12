module QueryCounter
  IGNORED_NAMES = %w[SCHEMA TRANSACTION].freeze

  def count_queries(&block)
    count = 0
    counter = lambda do |_name, _start, _finish, _id, payload|
      count += 1 unless IGNORED_NAMES.include?(payload[:name]) || payload[:cached]
    end

    ActiveSupport::Notifications.subscribed(counter, 'sql.active_record', &block)
    count
  end
end

RSpec.configure do |config|
  config.include QueryCounter
end
