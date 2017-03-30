require 'linkeddata'
require 'faraday'

module SparqlToSwSolr
  class InstanceSolrDoc

    # TODO: get these from settings.yml
    SPARQL_URL = 'http://127.0.0.1:8080/blazegraph/namespace/ld4p/sparql'.freeze
    # SPARQL_URL = 'http://localhost:8080/blazegraph/namespace/ld4p/sparql'.freeze
    # SPARQL_URL = 'http://sul-ld4p-blazegraph-dev.stanford.edu/blazegraph/namespace/ld4p/sparql'.freeze
    SPARQL_READ_TIMEOUT = 20
    SPARQL_CONN_TIMEOUT = 20
    RETRY_AFTER_LIMIT = 0
    RETRY_503 = 0
    BASE_URI = 'http://ld4p-test.stanford.edu/'.freeze
    BF_NS = 'http://id.loc.gov/ontologies/bibframe/'.freeze
    BF_NS_DECL = "PREFIX bf: <#{BF_NS}>".freeze

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
        doc = {}
        doc[:id] = instance_uri_to_ckey
        add_doc_title_fields(doc)
        doc
      end
    end

    private

    def add_doc_title_fields(doc)
      # TODO: When we get the bibframe ontology loaded into the graph.
      #       replace the filterstatement with this:
      # filter not exists { ?t a bf:VariantTitle ;
      #   rdfs:subClassOf bf:VariantTitle } .
      primary_title_query = "#{BF_NS_DECL}
        SELECT ?p ?o WHERE {
            <#{instance_uri}> bf:title ?t .
            ?t ?p ?o .
            filter not exists { ?t a bf:VariantTitle }
        }".freeze
      responsibility_query = "#{BF_NS_DECL}
        SELECT ?p ?o WHERE {
          <#{instance_uri}> bf:responsibilityStatement ?o .
          ?t ?p ?o
        }".freeze

      doc[:id] = instance_uri_to_ckey
      doc[:title_245a_search] = solution_values(['mainTitle'], primary_title_query)
      doc[:title_245_search] = solution_values(['rdf-schema#label'], primary_title_query)
      doc[:title_245a_display] = solution_values(['mainTitle'], primary_title_query)
      doc[:title_display] = solution_values(%w(mainTitle subtitle), primary_title_query)
      doc[:title_full_display] = "#{solution_values(%w(mainTitle subtitle), primary_title_query)} / " \
                                 "#{solution_values(['responsibilityStatement'], responsibility_query)}"
      doc
    end

    def instance_uri_to_ckey
      @ckey ||= self.class.instance_uri_to_ckey(@instance_uri)
    end

    def solution_values(property_array, query)
      json = json_sparql_result(query)
#      sparql_query_obj = sparql.query(query)
    # jj = json_sparql_result(@PRIMARY_TITLE_QUERY)
      values = ''
      sparql_query_obj.each_solution do |soln|
        property_array.each do |prop|
          values << soln.o.to_s if soln.p.end_with?(prop)
        end
      end
      values
    end

    def json_sparql_result(sparql_query)
      JSON.parse(sparql_response(sparql_query))
    end

    def sparql_response(sparql_query)
      response = sparql_conn.send(:post) do |request|
        request.body = "query=#{sparql_query}"
        request.headers['Accept'] = 'application/json'
      end
      raise StandardError("SPARQL HTTP failure: #{response.code}") unless response.success?
      response.body.force_encoding('utf-8')
    end

    def sparql_conn
      @connection ||= begin
        conn_opts = { request: {} }
        conn_opts[:request][:open_timeout] = SPARQL_CONN_TIMEOUT
        conn_opts[:request][:timeout] = SPARQL_READ_TIMEOUT
        conn_opts[:request][:params_encoder] = Faraday::FlatParamsEncoder

        Faraday.new({url: SPARQL_URL}, conn_opts) do |conn|
          conn.response :raise_error
          conn.request :retry, max: RETRY_AFTER_LIMIT, interval: 0.05,
                               interval_randomness: 0.5, backoff_factor: 2,
                               exceptions: ['Faraday::Error', 'Timeout::Error'] if RETRY_503
          conn.adapter Faraday.default_adapter
        end
      end
    end
  end
end
