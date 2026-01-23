Rails.autoloaders.main.push_dir(Rails.root.join("app/components"))
Rails.autoloaders.main.push_dir(Rails.root.join("app/views"))

Rails.application.config.to_prepare do
end