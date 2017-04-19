require 'linkeddata'
require_relative 'author_fields'
require_relative 'instance_pub_fields'
require_relative 'instance_title_fields'
require_relative 'language_field'
require_relative 'topic_fields'
require_relative 'physical_field'

module SparqlToSwSolr
  class InstanceSolrDoc
    include AuthorFields
    include InstancePubFields
    include InstanceTitleFields
    include LanguageField
    include TopicFields
    include PhysicalField

    # TODO: get these from settings.yml
    SPARQL_URL = 'http://localhost:8080/blazegraph/namespace/bibframe2_201704/sparql'.freeze
    # SPARQL_URL = 'http://localhost:8080/blazegraph/namespace/ld4p/sparql'.freeze
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
        doc[:physical] = physical_values
        add_author_fields(doc)
        add_publication_fields(doc)
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

    def solution_values_for_binding(solutions, binding_symbol)
      return unless binding_symbol.is_a?(Symbol)
      solutions.map do |soln|
        # need if clause for specs
        soln[binding_symbol].to_s if soln.bindings.keys.include?(binding_symbol)
      end
    end

    def concatenate_values(val1, separator, val2)
      [val1, val2].map(&:to_s).map(&:strip).reject(&:empty?).join(separator)
    end

    def sparql
      @sparql ||= SPARQL::Client.new(SPARQL_URL)
    end
  end
end
