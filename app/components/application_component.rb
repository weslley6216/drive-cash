# frozen_string_literal: true

class ApplicationComponent < Phlex::HTML
  # Rails View Helpers
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::DOMID
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Helpers::LinkTo

  # Rails I18n Helpers
  include Phlex::Rails::Helpers::T
  include Phlex::Rails::Helpers::L

  # Custom Helpers
  include Formatting

  # Utility method for CSS classes
  def class_names(*classes)
    classes.flatten.compact.join(' ')
  end

  def helpers
    view_context
  end

  def turbo_stream
    view_context.turbo_stream
  end
end
