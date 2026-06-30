source 'https://rubygems.org'

ruby '3.3.5'

gem 'rails', '~> 8.1.3'
gem 'pg', '~> 1.5'
gem 'solid_queue'
gem 'solid_cache'
gem 'puma', '>= 6.0'
gem 'faraday'
gem 'faraday-retry'
gem 'matrix'
gem 'prawn'
gem 'prawn-table'

# Transactional email over Resend's HTTP API (port 443) — works on hosts that
# block outbound SMTP ports, unlike :smtp delivery.
gem 'resend', '~> 1.5'

# Assets
gem 'importmap-rails'
gem 'propshaft'
gem 'stimulus-rails'
gem 'tailwindcss-rails'
gem 'turbo-rails'

# Phlex for components
gem 'phlex-rails', '~> 2.4.0'
gem 'phlex-icons', '~> 2.56'

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

gem 'bcrypt', '~> 3.1'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'
