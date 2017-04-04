module SparqlToSwSolr
  class InstanceSolrDoc
    module TopicFields

      private

      def add_doc_topic_fields(doc)
        doc[:topic_search] = topics
        doc[:topic_facet] = topics_facet
        doc
      end

      def topics
        @topics ||= begin
          results = sparql.query(topic_query)
          results.map { |r| chomp_nonwords r[:topicLabel] }
        end
      end

      def topics_facet
        topics.map { |topic| chomp_nonwords(first_topic(topic)) }
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

      def first_topic(topic)
        topic.to_s.split('--').first
      end

      def chomp_nonwords(topic)
        parsed = topic.to_s.gsub(/\W*$/, '')
        parsed += ')' if parsed =~ /[(]{1}\w*$/
        parsed
      end

    end
  end
end
