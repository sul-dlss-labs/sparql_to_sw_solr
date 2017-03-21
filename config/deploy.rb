set :application, 'sparql_to_sw_solr'
set :repo_url, 'https://github.com/sul-dlss/sparql_to_sw_solr.git'
set :deploy_host, "sul-ld4p-blazegraph-#{fetch(:stage)}.stanford.edu"
set :user, 'ld4p'

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/opt/app/#{fetch(:user)}/#{fetch(:application)}"

server fetch(:deploy_host), user: fetch(:user), roles: 'app'

# allow ssh to host
Capistrano::OneTimeKey.generate_one_time_key!

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, 'config/settings.yml'

# Default value for linked_dirs is []
append :linked_dirs, 'log'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# update shared_configs before restarting app
# before 'deploy:restart', 'shared_configs:update'

namespace :deploy do
  # needs to be in deploy namespace so deploy_host is defined properly (part of current_path)
  desc 'Temporary: delete doc 1234567890 from Solr'
  task :delete_1234567890_from_solr do
    on roles(:app) do
      execute "cd #{current_path} && bundle exec rake delete_1234567890_solr_doc"
    end
  end

  desc 'Temporary: add doc 1234567890 to Solr'
  task :add_1234567890_to_solr do
    on roles(:app) do
      execute "cd #{current_path} && bundle exec rake create_1234567890_solr_doc"
    end
  end
end
