# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

# Load the SCM plugin
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# ssh into boxes for deploy;  run bundle-audit on deploy ...
require 'capistrano/bundler'
require 'dlss/capistrano'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
