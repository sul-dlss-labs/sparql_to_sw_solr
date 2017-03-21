require 'bundler'
require 'rake'

task default: :ci

desc 'run continuous integration suite (tests, coverage, docs)'
task ci: [:spec, :rubocop]

begin
  require 'rspec/core/rake_task'
  desc 'Run RSpec'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  desc 'Run RSpec'
  task :spec do
    abort 'Please install the rspec gem to run tests.'
  end
end

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  desc 'Run rubocop'
  task :rubocop do
    abort 'Please install the rubocop gem to run rubocop.'
  end
end

require_relative 'lib/sparql_to_sw_solr'

desc 'Temporary: load solr doc 1234567890 for testing'
task :create_1234567890_solr_doc do
  instance_uri = 'http://ld4p-test.stanford.edu/1234567890#Instance'
  isd = SparqlToSwSolr::InstanceSolrDoc.new(instance_uri)
  isd.assemble_doc
  doc_hash = isd.solr_doc_hash

  ss = SparqlToSwSolr::SolrService.new
  ss.add_one_doc(doc_hash)
end

desc 'Temporary: delete solr doc 1234567890'
task :delete_1234567890_solr_doc do
  ss = SparqlToSwSolr::SolrService.new
  ss.delete_by_id('1234567890')
end
