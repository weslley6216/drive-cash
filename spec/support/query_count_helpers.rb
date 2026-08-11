module QueryCountHelpers
  def count_queries(&block)
    count = 0
    counter = lambda do |*, payload|
      count += 1 unless payload[:name].in?(%w[SCHEMA CACHE TRANSACTION])
    end

    ActiveSupport::Notifications.subscribed(counter, 'sql.active_record', &block)
    count
  end
end

RSpec.configure do |config|
  config.include QueryCountHelpers
end
