module Waiting
  def wait_until(&condition)
    Timeout.timeout(Capybara.default_max_wait_time) { sleep 0.05 until condition.call }
  end
end

RSpec.configure do |config|
  config.include Waiting, type: :system
end
