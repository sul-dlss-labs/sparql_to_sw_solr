module SparqlToSwSolr
  class InstanceSolrDoc

    attr_reader :instance_uri
    attr_reader :solr_doc_hash

    def initialize(instance_uri)
      @instance_uri = instance_uri
    end

    def assemble_doc
      doc = {}
      doc[:id] = instance_uri_to_ckey
      # TODO: write code
      @solr_doc_hash = doc
    end

    private

    def instance_uri_to_ckey
      # TODO: write code
      '1234567890'
    end
  end
end
