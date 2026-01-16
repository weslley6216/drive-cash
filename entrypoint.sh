#!/bin/bash

set -e

export TAILWIND_DISABLE_WATCHMAN=1

if [ "$(id -u)" = "0" ]; then
  mkdir -p /usr/local/bundle /app/tmp/pids
  chown -R appuser:appuser /usr/local/bundle /app

  echo "🎨 Building Tailwind CSS..."
  su -s /bin/bash -c 'bundle exec rails tailwindcss:build' appuser

  su -s /bin/bash -c 'rm -f tmp/pids/server.pid' appuser
  exec su -s /bin/bash -c "$*" appuser
fi

rm -f tmp/pids/server.pid
exec "$@"
