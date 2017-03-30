require 'bundler'
require 'rake'

task default: :ci

desc 'run continuous integration suite (tests, coverage, docs)'
task ci: %i(spec rubocop)

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

desc 'Temporary: delete sample solr docs'
task :delete_sample_solr_docs do
  ss = SparqlToSwSolr::SolrService.new
  require_relative 'config/sample_instance_uris'
  SAMPLE_INSTANCE_URIS.each do |uri|
    ss.delete_by_id(SparqlToSwSolr::InstanceSolrDoc.instance_uri_to_ckey(uri))
  end
  ss.commit # because no commit is sent separately
end

desc 'Temporary: load sample solr docs'
task :create_sample_solr_docs do
  ss = SparqlToSwSolr::SolrService.new
  require_relative 'config/sample_instance_uris'
  SAMPLE_INSTANCE_URIS.each do |uri|
    isd = SparqlToSwSolr::InstanceSolrDoc.new(uri)
    doc_hash = isd.solr_doc_hash
    if doc_hash.nil?
      puts 'nil doc_hash:  non-numeric ckey?'
      next
    end
    # puts doc_hash.to_s
    ss.add_one_doc(doc_hash) # includes commitWithin argument
  end
end
