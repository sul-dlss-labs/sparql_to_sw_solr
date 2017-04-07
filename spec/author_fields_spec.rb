RSpec.describe SparqlToSwSolr::InstanceSolrDoc::AuthorFields do

  let(:instance_uri) { 'http://ld4p-test.stanford.edu/1234567890#Instance' }
  let(:isd) { SparqlToSwSolr::InstanceSolrDoc.new(instance_uri) }
  let(:doc_hash) { isd.send(:add_author_fields, {}) }
  let(:sparql_conn) { double('sparql client') }
  let(:solutions) { RDF::Query::Solutions.new }

  before(:each) do
    allow(isd).to receive(:sparql).and_return(sparql_conn)
    expect(sparql_conn).to receive(:query).and_return(solutions).at_least(:once)
  end

  shared_examples 'single-valued field' do |solr_field_name|
    let(:bf_contributors) { ['Rustin, Jean', 'Arensi, Flavio'] }
    let(:solr_contributor) { doc_hash[solr_field_name] }

    it 'takes first label if there are multiple values' do
      bf_contributors.each do |bf_contributor|
        solutions << RDF::Query::Solution.new(p: 'rdf-schema#label', o: bf_contributor)
      end
      expect(solr_contributor).to be_a String
      expect(solr_contributor).to eq bf_contributors.first
    end
    it 'nil if there is no label' do
      expect(solr_contributor).to eq nil
    end
  end

  context 'author_1xx_search' do
    it_behaves_like 'single-valued field', :author_1xx_search
  end

  context 'author_sort' do
    it_behaves_like 'single-valued field', :author_sort
  end

  shared_examples 'multi-valued field' do |solr_field_name|
    let(:bf_contributors) { ['Rustin, Jean', 'Arensi, Flavio'] }
    let(:solr_contributor) { doc_hash[solr_field_name] }

    it 'Array when there are multiple values' do
      bf_contributors.each do |bf_contributor|
        solutions << RDF::Query::Solution.new(p: 'rdf-schema#label', o: bf_contributor)
      end
      expect(solr_contributor).to be_an Array
      expect(solr_contributor).to eq bf_contributors
    end
    it 'Array when there is a single value' do
      solutions << RDF::Query::Solution.new(p: 'rdf-schema#label', o: bf_contributors.first)
      expect(solr_contributor).to be_an Array
      expect(solr_contributor).to eq [bf_contributors.first]
    end
    it 'empty Array if there are no labels' do
      expect(solr_contributor).to eq []
    end
  end

  shared_examples 'display field' do |solr_field_name|
    it 'removes trailing spaces and \\.,:;/' do
      ['\\', '\.', ',', ':', ';', '/'].each do |punct|
        solutions << RDF::Query::Solution.new(p: 'rdf-schema#label', o: "foo#{punct}")
        expect(doc_hash[solr_field_name]).to eq ['foo']
      end
    end
    it 'removes trailing combinations of spaces and \\.,:;/' do
      solutions << RDF::Query::Solution.new(p: 'rdf-schema#label', o: "foo ;/: ")
      expect(doc_hash[solr_field_name]).to eq ['foo']
    end
    it 'removes leading whitespace' do
      solutions << RDF::Query::Solution.new(p: 'rdf-schema#label', o: " foo")
      expect(doc_hash[solr_field_name]).to eq ['foo']
    end
  end

  context 'author_person_display' do
    it_behaves_like 'multi-valued field', :author_person_display
    it_behaves_like 'display field', :author_person_display
  end

  context 'author_person_full_display' do
    it_behaves_like 'multi-valued field', :author_person_full_display
    it_behaves_like 'display field', :author_person_full_display
  end

  context 'author_person_facet' do
    it_behaves_like 'multi-valued field', :author_person_facet
    it_behaves_like 'display field', :author_person_facet
  end
end
