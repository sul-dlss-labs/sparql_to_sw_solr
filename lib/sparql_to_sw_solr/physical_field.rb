module SparqlToSwSolr
  class InstanceSolrDoc
    module PhysicalField

      private

      # Using the physical_solutions query below, extentLabel_1 and instanceDimensions_3
      # are always each the same value for every query solution; the note_case method
      # will collect each note information for the physical note types.
      def physical_values
        return if physical_solutions.empty?
        soln = physical_solutions.first
        @physical1 = soln.extentLabel_1.to_s
        @physical3 = soln.instanceDimensions_3.to_s
        physical_solutions.each_solution { |s| note_case(s) }
        physical_details # concatenate all the physical information
      end

      def note_case(soln)
        return unless soln.bindings.keys.include?(:noteType)
        case soln.noteType.to_s
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

      # extentLabel_1 and instanceDimensions_3 are required fields according to the MARC specification
      def physical_solutions
        @physical_solutions ||= begin
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
end
