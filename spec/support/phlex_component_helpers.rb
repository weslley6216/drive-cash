# frozen_string_literal: true

module PhlexComponentHelpers
  def view_context
    @view_context ||= begin
      controller = ApplicationController.new
      controller.request = ActionDispatch::TestRequest.create
      controller.view_context
    end
  end
end

RSpec.configure do |config|
  config.include PhlexComponentHelpers, type: :component

  config.before(:each, type: :component) do
    Rails.application.routes.default_url_options[:host] = 'test.host'
  end
end
