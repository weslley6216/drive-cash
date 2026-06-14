class ApplicationComponent < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::DOMID
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Helpers::LinkTo

  include Phlex::Rails::Helpers::T
  include Phlex::Rails::Helpers::L

  include Formatting

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
