require 'stanford-mods'

module SparqlToSwSolr
  class InstanceSolrDoc
    module InstancePubFields

      private

      def add_publication_fields(doc)
        add_pub_year_fields(doc)
        doc[:imprint_display] = imprint_display
        doc[:pub_search] = pub_search
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
        # for specificity in SW display ... if this were a marc or mods record ...
        # doc[:creation_year_isi]
        doc[:publication_year_isi] = @year_int
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

      def pub_year_solutions
        query = "#{BF_NS_DECL}
          SELECT ?pub_year WHERE {
            <#{instance_uri}> bf:provisionActivity ?prov_activity .
            ?prov_activity a bf:Publication ,
                  bf:ProvisionActivity .
            ?prov_activity bf:date ?pub_year .
             FILTER ( datatype(?pub_year) = <http://id.loc.gov/datatypes/edtf> ) .
          }"
        sparql.query(query)
      end

      def imprint_display
        edition = solution_values_for_binding(edition_solns, :edition).first
        pub_info = solution_values_for_binding(publication_solns, :pub_info).first
        concatenate_values(edition, ' - ', concatenate_values(pub_info, '. ', manu_info))
      end

      def manu_info
        soln = manufacture_solns.first
        manu_place = soln.manu_place.to_s if soln && soln.bindings.keys.include?(:manu_place)
        manu_agent = soln.manu_agent.to_s if soln && soln.bindings.keys.include?(:manu_agent)
        manu_date = soln.manu_date.to_s if soln && soln.bindings.keys.include?(:manu_date)
        concatenate_values(manu_place, ' : ', concatenate_values(manu_agent, ', ', manu_date))
      end

      def edition_solns
        query = "#{BF_NS_DECL}
          SELECT ?edition
          WHERE {
            <#{instance_uri}> bf:editionStatement ?edition
          }"
        sparql.query(query)
      end

      def publication_solns
        query = "#{BF_NS_DECL}
          SELECT ?pub_info
          WHERE {
            <#{instance_uri}> bf:provisionActivityStatement ?pub_info .
          }"
        sparql.query(query)
      end

      def manufacture_solns
        # the query below avoids Manufacture info from marc 008 by filtering to only blank nodes for place
        #   and filtering out edtf datatype for dates
        query = "#{BF_NS_DECL}
          SELECT ?manu_place ?manu_agent ?manu_date
          WHERE {
            <#{instance_uri}> bf:provisionActivity ?provision .
            ?provision a bf:Manufacture .

            OPTIONAL {
              ?provision bf:place ?place .
              FILTER isBlank (?place) .
              ?place rdfs:label ?manu_place .
            }
            OPTIONAL {
              ?provision bf:agent ?agent .
              ?agent rdfs:label ?manu_agent .
            }
            OPTIONAL {
              ?provision bf:date ?manu_date .
              FILTER (datatype(?manu_date) != <http://id.loc.gov/datatypes/edtf> )
            }
          }"
        sparql.query(query)
      end

      def pub_search
        result = ''
        provision_activity_solns.each do |soln|
          place = soln.place_val.to_s if soln && soln.bindings.keys.include?(:place_val)
          result << "#{place} " if searchable_place?(place)
          agent = soln.agent_val.to_s if soln && soln.bindings.keys.include?(:agent_val)
          result << "#{agent} " if searchable_agent?(agent)
        end
        result.strip unless result.strip.empty?
      end

      def searchable_place?(place)
        if !present?(place) || place.match(/.*s\.l\..*/i) || place.match(/.*place of .* not identified.*/i)
          false
        else
          true
        end
      end

      def searchable_agent?(agent)
        if !present?(agent) || agent.match(/.*s\.n\..*/i) || agent.match(/.*r not identified.*/i)
          false
        else
          true
        end
      end

      def provision_activity_solns
        # the query below avoids info from marc 008 by filtering to only blank nodes for place
        query = "#{BF_NS_DECL}
          SELECT ?place_val ?agent_val
          WHERE {
            <#{instance_uri}> a bf:Instance .
            <#{instance_uri}> bf:provisionActivity ?provision .

            OPTIONAL {
              ?provision bf:place ?place .
              FILTER isBlank (?place) .
              ?place rdfs:label ?place_val .
            }
            OPTIONAL {
              ?provision bf:agent ?agent .
              ?agent rdfs:label ?agent_val .
            }
          }"
        sparql.query(query)
      end

    end
  end
end
