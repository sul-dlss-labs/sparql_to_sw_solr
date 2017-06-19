set :application, 'sparql_to_sw_solr'
set :repo_url, 'https://github.com/sul-dlss/sparql_to_sw_solr.git'

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/opt/app/ld4p/sparql_to_sw_solr"

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
  desc 'Temporary: delete sample docs from Solr'
  task :delete_sample_solr_docs do
    on roles(:app) do
      execute "cd #{current_path} && bundle exec rake delete_sample_solr_docs"
    end
  end

  desc 'Temporary: add sample docs to Solr'
  task :add_sample_docs_to_solr do
    on roles(:app) do
      execute "cd #{current_path} && bundle exec rake create_sample_solr_docs"
    end
  end
end
