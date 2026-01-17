# frozen_string_literal: true

class ApplicationComponent < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::DOMID
  include Formatting

  def class_names(*classes)
    classes.flatten.compact.join(' ')
  end
end
