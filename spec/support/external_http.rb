require 'webmock/rspec'
require 'vcr'

module ExternalHttp
  def self.unhandled_requests
    @unhandled_requests ||= []
  end
end

WebMock.disable_net_connect!(allow_localhost: true)

VCR.configure do |config|
  config.cassette_library_dir = Rails.root.join('spec/fixtures/vcr_cassettes').to_s
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.ignore_localhost = true
  config.allow_http_connections_when_no_cassette = false
  config.default_cassette_options = { record: ENV['VCR_RECORD'] ? :once : :none, match_requests_on: %i[method uri] }
  config.before_http_request(:unhandled?) { |request| ExternalHttp.unhandled_requests << request.uri }
end

RSpec.configure do |config|
  config.after do
    attempted = ExternalHttp.unhandled_requests.dup
    ExternalHttp.unhandled_requests.clear
    raise "External HTTP attempted: #{attempted.join(', ')}" if attempted.any?
  end
end
