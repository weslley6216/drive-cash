source 'https://rubygems.org'

ruby '4.0.1'

gem 'rails', '~> 8.1.2'
gem 'pg', '~> 1.5'
gem 'puma', '>= 6.0'

# Assets
gem 'importmap-rails'
gem 'propshaft'
gem 'stimulus-rails'
gem 'tailwindcss-rails'
gem 'turbo-rails'

# Phlex for components
gem 'phlex-rails'

gem 'bootsnap', require: false

group :development, :test do
  gem 'debug', platforms: %i[ mri windows ]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'rubocop-rails-omakase', require: false
end

group :development do
  gem 'web-console'
  gem 'hotwire-livereload'
end

group :test do
  gem 'database_cleaner-active_record'
  gem 'shoulda-matchers'
  gem 'simplecov'
end
