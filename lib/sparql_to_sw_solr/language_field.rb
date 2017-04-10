require 'stanford-mods' # for SEARCHWORKS_LANGUAGES translation table

module SparqlToSwSolr
  class InstanceSolrDoc
    module LanguageField

      private

      def language_values
        result = []
        solution_values_for_binding(language_solutions, :lang).each do |soln_val|
          lang_code = soln_val[%r{^http://id.loc.gov/vocabulary/languages/(.*)}, 1]
          next unless lang_code && !lang_code.empty?
          # TODO: get lang_name from RDF at http://id.loc.gov/vocabulary/languages/
          lang_name = SEARCHWORKS_LANGUAGES[lang_code]
          result << (lang_name ? lang_name : lang_code)
        end
        result
      end

      def language_solutions
        query = "#{BF_NS_DECL}
          SELECT ?lang WHERE {
            <#{instance_uri}> bf:instanceOf ?work .
            ?work bf:language ?lang .
          }".freeze
        sparql.query(query)
      end

    end
  end
end
