module SparqlToSwSolr
  class InstanceSolrDoc

    # TODO: get these from settings.yml
    BASE_URI = 'http://ld4p-test.stanford.edu/'.freeze

    attr_reader :instance_uri
    attr_reader :solr_doc_hash

    def initialize(instance_uri)
      @instance_uri = instance_uri
    end

    # TODO: should solr_doc_hash be called in initialize method?
    def solr_doc_hash
      @solr_doc_hash ||= begin
        return unless instance_uri_to_ckey
        doc = {}
        doc[:id] = instance_uri_to_ckey
        doc
      end
    end

    private

    # marc2bibframe2 Instance URI format: http://ld4p-test.stanford.edu/666#Instance
    def instance_uri_to_ckey
      @iid ||= @instance_uri.split(BASE_URI).last.chomp('#Instance')
      return false unless @iid =~ /\A\d+\z/
      @iid
    end
  end
end
