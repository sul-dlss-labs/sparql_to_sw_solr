module SparqlToSwSolr
  class InstanceSolrDoc
    module InstanceTitleFields

      private

      def add_title_fields(doc)
        # TODO: what if primary title values aren't single values?
        primary_solutions = primary_title_result
        primary_main_title = values_from_solutions(primary_solutions, 'mainTitle').first
        doc[:title_245a_search] = primary_main_title
        doc[:title_245_search] = values_from_solutions(primary_solutions, 'rdf-schema#label').first
        doc[:title_245a_display] = primary_main_title.strip.gsub(/[\\,:;\/ ]+$/, '') if primary_main_title
        primary_subtitle = values_from_solutions(primary_solutions, 'subtitle').first
        # TODO: what should separator be? what if main title ends with '=' ?
        doc[:title_display] = "#{primary_main_title.strip.gsub(/[\\,:;\/ ]+$/, '') if primary_main_title}" \
                              "#{present?(primary_subtitle) && present?(primary_main_title) ? ' : ' : nil}" \
                              "#{primary_subtitle.strip.gsub(/[\\,:;\/ ]+$/, '') if primary_subtitle}"
        resp_statement = values_from_solutions(primary_solutions, 'responsibilityStatement').first
        doc[:title_full_display] = "#{doc[:title_display]}" \
                                   "#{present?(doc[:title_display]) && present?(resp_statement) ? ' / ' : nil}" \
                                   "#{resp_statement.gsub(/[\\,:;\/ ]+$/, '') if resp_statement}"
        doc
      end

      def primary_title_result
        # TODO: When we get the bibframe ontology loaded into the graph.
        #       replace the filter statement with this:
        # filter not exists { ?t a bf:VariantTitle ;
        #   rdfs:subClassOf bf:VariantTitle } .
        query = "#{BF_NS_DECL}
          SELECT ?p ?o WHERE {
            {
              <#{instance_uri}> bf:title ?t .
              ?t ?p ?o .
              FILTER NOT EXISTS { ?t a bf:VariantTitle } .
            } UNION {
              <#{instance_uri}> bf:responsibilityStatement ?o .
              ?ignore ?p ?o
            }
          }".freeze
        sparql.query(query)
      end

      def present?(string)
        string && !string.empty?
      end
    end
  end
end
