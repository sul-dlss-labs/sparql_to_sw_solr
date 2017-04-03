require 'linkeddata'
require_relative 'author_fields'
require_relative 'instance_title_fields'
require_relative 'language_field'
require_relative 'topic_fields'

module SparqlToSwSolr
  class InstanceSolrDoc
    include AuthorFields
    include InstanceTitleFields
    include LanguageField
    include TopicFields

    # TODO: get these from settings.yml
    SPARQL_URL = 'http://localhost:8080/blazegraph/namespace/ld4p/sparql'.freeze
    # SPARQL_URL = 'http://sul-ld4p-blazegraph-dev.stanford.edu/blazegraph/namespace/ld4p/sparql'.freeze
    BASE_URI = 'http://ld4p-test.stanford.edu/'.freeze

    BF_NS = 'http://id.loc.gov/ontologies/bibframe/'.freeze
    BF_NS_DECL = "PREFIX bf: <#{BF_NS}>".freeze

    DOC_SOURCE = 'Bibframe'.freeze

    attr_reader :instance_uri
    attr_reader :solr_doc_hash

    # marc2bibframe2 Instance URI format: http://ld4p-test.stanford.edu/666#Instance
    def self.instance_uri_to_ckey(uri)
      ckey ||= uri.split(BASE_URI).last.chomp('#Instance')
      return false unless ckey =~ /\A\d+\z/
      ckey
    end

    def initialize(instance_uri)
      @instance_uri = instance_uri
    end

    # TODO: should solr_doc_hash be called in initialize method?
    def solr_doc_hash
      @solr_doc_hash ||= begin
        return unless instance_uri_to_ckey
        return if CKEY_BLACKLIST.include?(@ckey)
        doc = init_doc
        doc[:language] = language_values
        add_author_fields(doc)
        add_title_fields(doc)
        add_topic_fields(doc)
        doc
      end
    end

    private

    def init_doc
      doc = {}
      doc[:id] = instance_uri_to_ckey
      doc[:format_main_ssim] = 'Book'
      doc[:access_facet] = DOC_SOURCE
      doc[:collection] = DOC_SOURCE
      doc
    end

    def instance_uri_to_ckey
      @ckey ||= self.class.instance_uri_to_ckey(@instance_uri)
    end

    # SPARQL results expected to have "p" for predicate and "o" for object as results
    def values_from_solutions(solutions, predicate_name)
      values = []
      solutions.each_solution do |soln|
        # need next line for specs
        next unless soln.bindings.keys.include?(:o) && soln.bindings.keys.include?(:p)
        values << soln.o.to_s if soln.p.end_with?(predicate_name)
      end
      values
    end

    def sparql
      @sparql ||= SPARQL::Client.new(SPARQL_URL)
    end
  end
end
