class ApplicationView < ApplicationComponent
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::ButtonTo
  include ModalHeader
  include ModalStyles
  include FormFields
  include ButtonStyles
end
