ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start 'rails' do
  add_filter 'channels'
  add_filter 'mailers'
  add_filter 'jobs'
end

SimpleCov.minimum_coverage 100

require_relative '../config/environment'

abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'

Rails.root.glob('spec/support/**/*.rb').sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.filter_rails_from_backtrace!
  
  config.before(:each, type: :component) do
    Rails.application.routes.default_url_options[:host] = 'test.host'
  end
end
