module SparqlToSwSolr
  class InstanceSolrDoc
    module PhysicalField

      private

      def physical_values
        physical_solutions.each_solution do |soln|
          next unless soln.bindings.keys.include?(:noteType)
          @note_type = soln.noteType.to_s
          @physical1 = soln.extentLabel_1.to_s
          @physical3 = soln.instanceDimensions_3.to_s
          note_case(soln)
        end
        physical_details
      end

      def note_case(soln)
        case @note_type
        when 'Physical details'
          @physical2 = soln.noteLabel.to_s
        when 'Accompanying materials'
          @physical4 = soln.noteLabel.to_s
        end
      end

      def physical_details
        extent_details = concatenate_values(@physical1, ' : ', @physical2)
        extent_details_dimensions = concatenate_values(extent_details, ' ; ', @physical3)
        concatenate_values(extent_details_dimensions, ' + ', @physical4)
      end

      def physical_solutions
        query = "#{BF_NS_DECL}
        SELECT distinct ?extentLabel_1 ?noteType ?noteLabel ?instanceDimensions_3
        WHERE {
          <#{instance_uri}> bf:extent ?e .
          ?e rdfs:label ?extentLabel_1 .
          <#{instance_uri}> bf:dimensions ?instanceDimensions_3 .
          OPTIONAL {
            <#{instance_uri}> bf:note ?note .
            ?note bf:noteType ?noteType;
            	  rdfs:label ?noteLabel .
          }
        }
        ".freeze
        sparql.query(query)
      end
    end
  end
end
