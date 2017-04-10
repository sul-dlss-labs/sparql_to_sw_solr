require 'stanford-mods'

module SparqlToSwSolr
  class InstanceSolrDoc
    module InstancePubFields

      private

      def add_publication_fields(doc)
        add_pub_year_fields(doc)
        doc[:imprint_display] = ''
        doc[:pub_search] = ''
        doc
      end

      def add_pub_year_fields(doc)
        init_year_fields
        # year for sorting
        doc[:pub_year_isi] = @year_int # new way (not yet used)
        doc[:pub_date_sort] = @sort_str # old way, used in SW, but to be replaced by pub_year_isi
        # date slider; NOTE: single valued for now
        doc[:pub_year_tisim] = @year_int # (multivalued, date slider)
        # year for display
        doc[:pub_year_ss] = @year_display_str # new way (used for mods)
        doc[:pub_date] = @year_display_str # old way, for display string ??  replaced by specific ones?
        # for specificity in display ...
        # doc[:creation_year_isi]
        doc[:publication_year_isi] = @year_int
      end

      def pub_year_solutions
        query = "#{BF_NS_DECL}
          SELECT ?pub_year WHERE {
            <#{instance_uri}> a bf:Instance ;
              bf:provisionActivity ?prov_activity .
            ?prov_activity a bf:Publication ,
                  bf:ProvisionActivity .
            ?prov_activity bf:date ?pub_year .
             FILTER ( datatype(?pub_year) = <http://id.loc.gov/datatypes/edtf> ) .
          }"
        sparql.query(query)
      end

      def init_year_fields
        solution_values_for_binding(pub_year_solutions, :pub_year).each do |value|
          value = value[0, 4]
          @year_int ||= Stanford::Mods::DateParsing.year_int_from_date_str(value)
          @year_display_str ||= Stanford::Mods::DateParsing.date_str_for_display(value)
          @sort_str ||= Stanford::Mods::DateParsing.sortable_year_string_from_date_str(value)
          break if @year_int && @year_display_str && @sort_str
        end
      end
    end
  end
end
