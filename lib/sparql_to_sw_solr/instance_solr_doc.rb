require 'linkeddata'
require_relative 'instance_title_fields'

module SparqlToSwSolr
  class InstanceSolrDoc
    include InstanceTitleFields

    # TODO: get these from settings.yml
    SPARQL_URL = 'http://localhost:8080/blazegraph/namespace/ld4p/sparql'.freeze
    # SPARQL_URL = 'http://sul-ld4p-blazegraph-dev.stanford.edu/blazegraph/namespace/ld4p/sparql'.freeze
    BASE_URI = 'http://ld4p-test.stanford.edu/'.freeze
    BF_NS = 'http://id.loc.gov/ontologies/bibframe/'.freeze
    MADSRDF = 'http://www.loc.gov/mads/rdf/v1#'.freeze

    DOC_SOURCE = 'bibframe'.freeze

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
        add_doc_title_fields(doc)
        doc
      end
    end

    def sparql_prefixes
      @sparql_prefixes ||= begin
        bf = "PREFIX bf: <#{BF_NS}>"
        mads = "PREFIX madsrdf: <#{MADSRDF}>"
        [bf, mads].join("\n")
      end
    end

    def sparql_query(query)
      sparql.query(sparql_prefixes + query)
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
        values << soln.o.to_s if soln.p.end_with?(predicate_name)
      end
      values
    end

    def sparql
      @sparql ||= SPARQL::Client.new(SPARQL_URL)
    end
  end
end
