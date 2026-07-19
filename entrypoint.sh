#!/bin/bash

set -e

if [ "$(id -u)" = "0" ]; then
  mkdir -p /usr/local/bundle /app/tmp/pids
  chown -R appuser:appuser /usr/local/bundle
  chown appuser:appuser /app/tmp /app/tmp/pids
  rm -f /app/tmp/pids/server.pid

  exec su -s /bin/bash -c "$*" appuser
fi

rm -f tmp/pids/server.pid
exec "$@"
