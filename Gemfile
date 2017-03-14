source 'https://rubygems.org'

gem 'rake'
gem 'rsolr'

group :test do
  gem 'rspec'
  gem 'coveralls', require: false
end

group :development, :test do
  # Call 'binding.pry' anywhere in the code to stop execution and get a debugger console
  gem 'pry-byebug'
  gem 'rubocop'
  gem 'rubocop-rspec'
end

group :deployment do
  gem 'capistrano', '~> 3.0'
  gem 'capistrano-bundler'
  gem 'dlss-capistrano'
end
