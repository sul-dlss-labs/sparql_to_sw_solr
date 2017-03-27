module SparqlToSwSolr
  class InstanceSolrDoc

    # TODO: get this from settings.yml
    BASE_URI = 'http://ld4p-test.stanford.edu/'.freeze

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
        doc
      end
    end

    private

    def instance_uri_to_ckey
      @ckey ||= self.class.instance_uri_to_ckey(@instance_uri)
    end
  end
end
