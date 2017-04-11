module SparqlToSwSolr
  class InstanceSolrDoc
    module InstanceTitleFields

      private

      def add_title_fields(doc)
        # TODO: what if primary title values aren't single values?
        primary_solutions = primary_title_result
        # TODO: is this appropriate if primary title values aren't single values?
        primary_main_title = values_from_solutions(primary_solutions, 'mainTitle').first
        doc[:title_245a_search] = primary_main_title
        doc[:title_245_search] = values_from_solutions(primary_solutions, 'rdf-schema#label').first

        primary_main_title_no_punct = scrub_title_val(primary_main_title)
        doc[:title_245a_display] = primary_main_title_no_punct

        primary_subtitle = scrub_title_val(values_from_solutions(primary_solutions, 'subtitle').first)
        # TODO: what if main title ends with '=' ?
        doc[:title_display] = concatenate_values(primary_main_title_no_punct, ' : ', primary_subtitle)

        resp_statement = scrub_title_val(values_from_solutions(primary_solutions, 'responsibilityStatement').first)
        doc[:title_full_display] = concatenate_values(doc[:title_display], ' / ', resp_statement)
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

      # SPARQL results expected to have "p" for predicate and "o" for object as results
      def values_from_solutions(solutions, predicate_name)
        values = []
        solutions.each_solution do |soln|
          # need next line for specs
          next unless soln.bindings.keys.include?(:o) && soln.bindings.keys.include?(:p)
          values << soln.o.to_s if soln.p.end_with?(predicate_name)
        end
        values
      end

      # remove leading and trailing whitespace;
      # remove trailing chars \,:;/
      def scrub_title_val(val)
        val.strip.gsub(/[\\,:;\/ ]+$/, '') if val
      end

      def present?(string)
        string && !string.empty?
      end
    end
  end
end
