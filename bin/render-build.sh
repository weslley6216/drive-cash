#!/usr/bin/env bash
set -o errexit

echo "=== Installing dependencies ==="
bundle install

echo "=== Building Tailwind CSS ==="
bin/rails tailwindcss:build

echo "=== Precompiling assets ==="
RAILS_ENV=production bundle exec rails assets:precompile

echo "=== Running migrations ==="
bin/rails db:migrate
