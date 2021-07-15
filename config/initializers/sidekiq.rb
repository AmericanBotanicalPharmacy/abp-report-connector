Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://0.0.0.0:6379/0' }
end

schedule_file = "config/schedule.yml"

if File.exist?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end