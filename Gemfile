source 'https://rubygems.org'

gem 'rake'
gem 'rsolr', '>= 2.0.0.pre1', '< 3' # want Faraday with retries for 503, timeout

gem 'linkeddata'
gem 'rdf-vocab', '>= 2.2.2' # for BF2 vocabulary
gem 'stanford-mods' # for pub year date parsing

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
