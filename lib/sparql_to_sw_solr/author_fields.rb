module SparqlToSwSolr
  class InstanceSolrDoc
    module AuthorFields

      private

      def add_author_fields(doc)
        primary_contributor = values_from_solutions(primary_contributor_result, 'rdf-schema#label').first
        doc[:author_1xx_search] = primary_contributor
        doc[:author_sort] = primary_contributor

        contributor_persons = values_from_solutions(contributor_person_result, 'rdf-schema#label')
        contributor_persons_no_punct = contributor_persons.map { |c| c.strip.gsub(/[\\.,:;\/ ]+$/, '') }
        doc[:author_person_display] = contributor_persons_no_punct
        # trailing punctuation removed from author_person_full_display since we aren't getting roles and
        # we have bibframe data like "Verdi, Giuseppe, 1813-1901," converted from MARC data like
        # "Verdi, Giuseppe, 1813-1901, composer."
        doc[:author_person_full_display] = contributor_persons_no_punct
        doc[:author_person_facet] = contributor_persons_no_punct

        doc
      end

      def primary_contributor_result
        query = "#{BF_NS_DECL}
          SELECT ?p ?o WHERE {
            <#{instance_uri}> bf:instanceOf ?work .
            ?work bf:contribution ?contribution .
            ?contribution a <http://id.loc.gov/ontologies/bflc/PrimaryContribution> ;
              bf:agent ?agent .
            ?agent rdfs:label ?o ;
              ?p ?o
          }
        ".freeze
        sparql.query(query)
      end

      def contributor_person_result
        query = "#{BF_NS_DECL}
          SELECT ?p ?o WHERE {
            <#{instance_uri}> bf:instanceOf ?work .
            ?work bf:contribution ?contribution .
            ?contribution bf:agent ?agent .
            ?agent a bf:Agent, bf:Person ;
              rdfs:label ?o .
            ?agent ?p ?o
          }
        ".freeze
        sparql.query(query)
      end

    end
  end
end
