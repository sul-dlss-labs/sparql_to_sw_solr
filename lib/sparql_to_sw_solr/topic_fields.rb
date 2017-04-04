module SparqlToSwSolr
  class InstanceSolrDoc
    module TopicFields

      private

      def add_doc_topic_fields(doc)
        doc[:topic_search] = topics
        doc[:topic_facet] = topics
        doc
      end

      def topics
        @topics ||= begin
          results = sparql.query(topic_query)
          results.map { |t| topic_parse t[:topicLabel] }
        end
      end

      def topic_parse(topic)
        t = topic.to_s.split('--').first
        t.gsub(/\W*$/, '')
      end

      def topic_query
        @topic_query ||= "
          #{BF_NS_DECL}
          #{MADSRDF_NS_DECL}
          SELECT ?topicLabel
          WHERE {
            <#{instance_uri}> bf:instanceOf ?work .
            ?work bf:subject ?topic .
            ?topic a bf:Topic ;
                   madsrdf:authoritativeLabel ?topicLabel .
          }"
      end

    end
  end
end
