# config valid for current version and patch releases of Capistrano
lock "~> 3.16.0"

set :application,     'abp-report'
set :repo_url,        'git@github.com:AmericanBotanicalPharmacy/abp-report-connector.git'
set :user,            'ubuntu'
set :deploy_via,      :remote_cache
ask :branch,          `git rev-parse --abbrev-ref HEAD`.chomp
set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/herbdoc-dev.pem) }

# Linked fies and dirs
append :linked_files, '.env', 'config/master.key', 'config/credentials.yml.enc'
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads'

# Change migration_role to :app
set :migration_role, :app

# Puma config
set :puma_preload_app, true
set :puma_init_active_record, true  # Change to false when not using ActiveRecord
set :puma_service_unit_name, "#{fetch(:application)}-puma"
set :puma_bind, -> { File.join("unix://#{shared_path}", 'tmp', 'sockets', "#{fetch(:application)}-puma.sock") }

# Sidekiq config
set :sidekiq_user, :user
set :sidekiq_service_unit_user, :system
set :sidekiq_service_unit_name, "#{fetch(:application)}-sidekiq"

namespace :deploy do
  desc 'Upload config files.'
  task :upload_config_files do
    on roles(:app) do
      execute "mkdir -p #{shared_path}/config"
      upload!("config/master.key", "#{shared_path}/config/master.key")
      upload!("config/credentials.yml.enc", "#{shared_path}/config/credentials.yml.enc")
      upload!(".env", "#{shared_path}/.env")
    end
  end
end

task :log do
  on roles(:app) do
    execute "cd #{shared_path}/log && tail -f #{fetch(:stage)}.log"
  end
end
