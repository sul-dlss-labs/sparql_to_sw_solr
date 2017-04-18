module SparqlToSwSolr
  class InstanceSolrDoc
    module InstanceStdNumFields

      private

      def add_std_num_fields(doc)
        doc[:oclc] = oclc_nums
        doc[:lccn] = lccn # single valued Solr field
        doc[:isbn_display] = isbn_display_vals
        doc
      end

      # see https://github.com/sul-dlss/solrmarc-sw/blob/master/stanford-sw/ ...
      #     ... src/edu/stanford/StanfordIndexer.java#L792-#L836
      #   we look for bf:Local identifiers with label OCoLC-M first
      #   if none, we look for bf:Local identifiers with label OCoLC
      #   we do not seek values prefixed 'ocn', 'ocm' or 'on' because the solrmarc algorithm seeks
      #    those in 079, which are not converted.
      def oclc_nums
        ocolc_m = []
        ocolc = []
        oclc_solns.each do |soln|
          # need if clauses for specs
          value = soln.value.to_s.strip if soln && soln.bindings.keys.include?(:value)
          label = soln.label.to_s.strip if soln && soln.bindings.keys.include?(:label)
          case label
          when 'OCoLC-M'
            ocolc_m << value if present?(value)
          when 'OCoLC'
            ocolc << value if present?(value)
          end
        end
        return ocolc_m unless ocolc_m.empty?
        ocolc
      end

      def oclc_solns
        query = "#{BF_NS_DECL}
          SELECT ?value ?label WHERE {
            <#{instance_uri}> bf:identifiedBy ?i .
            ?i a bf:Local ;
               rdf:value ?value ;
               bf:source ?src .
            ?src rdfs:label ?label
          }"
        sparql.query(query)
      end

      # lccn is a single valued Solr field
      def lccn
        invalid = []
        lccn_solns.each do |soln|
          # need if clauses for specs
          value = soln.lccn_value.to_s if soln && soln.bindings.keys.include?(:lccn_value)
          label = soln.status_label.to_s.strip if soln && soln.bindings.keys.include?(:status_label)
          return value unless present?(label)
          invalid << value if label == 'invalid'
        end
        return invalid.first unless invalid.empty?
      end

      def lccn_solns
        query = "#{BF_NS_DECL}
          SELECT ?lccn_value ?status_label WHERE {
            <#{instance_uri}> bf:identifiedBy ?i .
            ?i a bf:Lccn ;
               rdf:value ?lccn_value .
            OPTIONAL {
              ?i bf:status ?status .
              ?status a bf:Status ;
                      rdfs:label ?status_label
            }
          }"
        sparql.query(query)
      end

      def isbn_display_vals
        valid = []
        invalid = []
        isbn_display_solns.each do |soln|
          # need if clauses for specs
          value = soln.isbn_value.to_s.strip if soln && soln.bindings.keys.include?(:isbn_value)
          label = soln.status_label.to_s.strip if soln && soln.bindings.keys.include?(:status_label)
          valid << value unless present?(label)
          invalid << value if label == 'invalid'
        end
        return valid unless valid.empty?
        invalid
      end

      def isbn_display_solns
        query = "#{BF_NS_DECL}
          SELECT ?isbn_value ?status_label WHERE {
            <#{instance_uri}> bf:identifiedBy ?i .
            ?i a bf:Isbn ;
               rdf:value ?isbn_value .
            OPTIONAL {
              ?i bf:status ?status .
              ?status a bf:Status ;
                      rdfs:label ?status_label
            }
          }"
        sparql.query(query)
      end
    end
  end
end
