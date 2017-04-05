module SparqlToSwSolr
  class InstanceSolrDoc
    module TopicFields

      private

      def add_topic_fields(doc)
        doc[:topic_search] = topics
        doc[:topic_facet] = topics_facet
        doc
      end

      def topics
        @topics ||= sparql.query(topic_query).map do |result|
          result[:topicLabel].to_s
        end
      end

      def topics_facet
        @topics_facet ||= topics.map { |topic| chomp_nonwords(first_topic(topic)) }
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
        topic.split('--').first
      end

      def chomp_nonwords(topic)
        topic.gsub(/[\\,:;\/\s]*$/, '')
      end

    end
  end
end
