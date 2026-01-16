# frozen_string_literal: true

Rails.autoloaders.main.push_dir(Rails.root.join("app/views/components"))

Rails.application.config.to_prepare do
end
