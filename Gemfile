source "https://rubygems.org"

ruby "4.0.1"

gem "rails", "~> 8.1.2"
gem "pg", "~> 1.5"
gem "puma", ">= 6.0"

# Assets
gem "propshaft"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"

# Phlex for components
gem "phlex-rails"

gem "bootsnap", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "shoulda-matchers"
  gem 'database_cleaner'
end
