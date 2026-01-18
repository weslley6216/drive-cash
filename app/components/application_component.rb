# frozen_string_literal: true

class ApplicationComponent < Phlex::HTML
  # Rails View Helpers
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::DOMID

  # Rails I18n Helpers
  include Phlex::Rails::Helpers::T
  include Phlex::Rails::Helpers::L

  # Custom Helpers
  include Formatting

  def class_names(*classes)
    classes.flatten.compact.join(' ')
  end
end
