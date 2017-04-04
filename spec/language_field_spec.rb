RSpec.describe SparqlToSwSolr::InstanceSolrDoc::LanguageField do

  let(:instance_uri) { 'http://ld4p-test.stanford.edu/1234567890#Instance' }
  let(:isd) { SparqlToSwSolr::InstanceSolrDoc.new(instance_uri) }
  let(:sparql_conn) { double('sparql client') }
  let(:solutions) { RDF::Query::Solutions.new }

  before(:each) do
    allow(isd).to receive(:sparql).and_return(sparql_conn)
    allow(sparql_conn).to receive(:query).and_return(solutions)
  end

  context '#language_values' do
    it 'is an Array of translated codes, even when there is only a single value' do
      solutions << RDF::Query::Solution.new(lang: RDF::URI('http://id.loc.gov/vocabulary/languages/ita'))
      lang_values = isd.send(:language_values)
      expect(lang_values).to be_an Array
      expect(lang_values).to eq ['Italian']
    end
    it 'includes all translated codes (Array) when there are multiple language values' do
      solutions << RDF::Query::Solution.new(lang: RDF::URI('http://id.loc.gov/vocabulary/languages/ita'))
      solutions << RDF::Query::Solution.new(lang: RDF::URI('http://id.loc.gov/vocabulary/languages/spa'))
      solutions << RDF::Query::Solution.new(lang: RDF::URI('http://id.loc.gov/vocabulary/languages/fre'))
      lang_values = isd.send(:language_values)
      expect(lang_values).to eq ['Italian', 'Spanish', 'French']
    end
    it 'uses raw language code if there is no translation in SEARCHWORKS_LANGUAGES' do
      solutions << RDF::Query::Solution.new(lang: RDF::URI('http://id.loc.gov/vocabulary/languages/foo'))
      solutions << RDF::Query::Solution.new(lang: RDF::URI('http://id.loc.gov/vocabulary/languages/1234'))
      lang_values = isd.send(:language_values)
      expect(lang_values).to eq ['foo', '1234']
    end
    it 'takes the language values from the Work, not the Instance' do
      expect(sparql_conn).to receive(:query).with(a_string_matching('instanceOf')).and_return(solutions)
      isd.send(:language_solutions)
    end

    context 'returns empty Array when' do
      it 'there are no language values returned via sparql' do
        lang_values = isd.send(:language_values)
        expect(lang_values).to eq []
      end
      it 'language code is empty string' do
        solutions << RDF::Query::Solution.new(lang: RDF::URI('http://id.loc.gov/vocabulary/languages/'))
        lang_values = isd.send(:language_values)
        expect(lang_values).to eq []
      end
      it 'sparql solution value is not URI' do
        solutions << RDF::Query::Solution.new(lang: 'I am not a URI')
        lang_values = isd.send(:language_values)
        expect(lang_values).to eq []
      end
      it 'sparql solution is not URI beginning "http://id.loc.gov/vocabulary/languages/"' do
        solutions << RDF::Query::Solution.new(lang: RDF::URI('http://something.else.org/ita'))
        lang_values = isd.send(:language_values)
        expect(lang_values).to eq []
      end
    end
  end
end
