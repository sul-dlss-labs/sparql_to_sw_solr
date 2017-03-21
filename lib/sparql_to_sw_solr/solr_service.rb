require 'forwardable'
require 'rsolr'

module SparqlToSwSolr
  class SolrService
    extend Forwardable

    # TODO: get these from settings.yml
    SOLR_URL = 'https://sul-solr.stanford.edu/solr/searchworks-rdf-dev'.freeze
    READ_TIMEOUT = 120
    OPEN_TIMEOUT = 120
    NUM_TIMES_RETRY_503 = 1
    COMMIT_WITHIN = 100

    def_delegators :conn, :delete_by_id

    def initialize
      @conn_options = {
        read_timeout: READ_TIMEOUT,
        open_timeout: OPEN_TIMEOUT,
        url: SOLR_URL,
        retry_503: NUM_TIMES_RETRY_503
      }
    end

    def add_one_doc(solr_doc_hash)
      conn.add(solr_doc_hash, add_attributes: { commitWithin: COMMIT_WITHIN })
    end

    private

    def conn
      @conn ||= RSolr.connect @conn_options
    end

  end
end
