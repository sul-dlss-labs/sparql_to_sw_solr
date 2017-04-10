module SparqlToSwSolr
  class InstanceSolrDoc
    module AuthorFields

      private

      def add_author_fields(doc)
        primary_contributor = solution_values_for_binding(primary_contributor_solns, :primary_author).first
        doc[:author_1xx_search] = primary_contributor
        doc[:author_sort] = primary_contributor

        author_persons = solution_values_for_binding(contributor_person_solns, :author_person)
        author_persons_no_punct = author_persons.map { |c| c.strip.gsub(/[\\.,:;\/ ]+$/, '') if c }
        doc[:author_person_display] = author_persons_no_punct
        # NOTE: populating author_person_full_display causes duplicate author fields to show in the record view
        #   We *will* want this field (tho possibly with orig punct) once we add the role info to it (see #37)
        # doc[:author_person_full_display] = author_persons_no_punct
        doc[:author_person_facet] = author_persons_no_punct

        doc
      end

      def primary_contributor_solns
        query = "#{BF_NS_DECL}
          SELECT ?primary_author WHERE {
            <#{instance_uri}> bf:instanceOf ?work .
            ?work bf:contribution ?contribution .
            ?contribution a <http://id.loc.gov/ontologies/bflc/PrimaryContribution> ;
              bf:agent ?agent .
            ?agent rdfs:label ?primary_author
          }
        ".freeze
        sparql.query(query)
      end

      def contributor_person_solns
        query = "#{BF_NS_DECL}
          SELECT ?author_person WHERE {
            <#{instance_uri}> bf:instanceOf ?work .
            ?work bf:contribution ?contribution .
            ?contribution bf:agent ?agent .
            ?agent a bf:Agent, bf:Person ;
              rdfs:label ?author_person
          }
        ".freeze
        sparql.query(query)
      end

    end
  end
end
