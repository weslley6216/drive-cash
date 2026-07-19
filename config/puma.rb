max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

rails_env = ENV.fetch("RAILS_ENV") { "development" }
environment rails_env

case rails_env
when "production"
  workers ENV.fetch("WEB_CONCURRENCY") { 2 }
  preload_app!
when "development"
  worker_timeout 3600
end

port ENV.fetch("PORT") { 3000 }

pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

plugin :tmp_restart
