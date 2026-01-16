# frozen_string_literal: true

class ApplicationComponent < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::DOMID

  def class_names(*classes)
    classes.flatten.compact.filter_map { |klass| klass if klass.present? }.join(" ")
  end
end
