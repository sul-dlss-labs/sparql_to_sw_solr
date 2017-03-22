RSpec.describe SparqlToSwSolr::InstanceSolrDoc::InstanceTitleFields do

  let(:instance_uri) { 'http://ld4p-test.stanford.edu/1234567890#Instance' }
  let(:isd) { SparqlToSwSolr::InstanceSolrDoc.new(instance_uri) }

  it 'instance_uri has a value in the context of InstanceTitleFields module' do
    expect(isd.instance_uri).to eq instance_uri
  end

  context 'add_doc_title_fields' do
    let(:doc_hash) { isd.send(:add_doc_title_fields, {}) }
    let(:solutions) { RDF::Query::Solutions.new }

    context 'title_245a_search' do
      let(:sparql_conn) { double('sparql client') }
      before(:each) do
        allow(isd).to receive(:sparql).and_return(sparql_conn)
      end
      it 'is a String (not an Array - single valued Solr field' do
        solutions << RDF::Query::Solution.new(p: 'bf:mainTitle', o: 'foo')
        expect(sparql_conn).to receive(:query).and_return(solutions)
        expect(doc_hash[:title_245a_search]).to be_a String
        expect(doc_hash[:title_245a_search]).to eq 'foo'
      end
      it 'takes first mainTitle if there are multiple values' do
        solutions << RDF::Query::Solution.new(p: 'bf:mainTitle', o: 'foo')
        solutions << RDF::Query::Solution.new(p: 'bf:mainTitle', o: 'bar')
        expect(sparql_conn).to receive(:query).and_return(solutions)
        expect(doc_hash[:title_245a_search]).to eq 'foo'
      end
      it 'nil if there is no mainTitle' do
        expect(sparql_conn).to receive(:query).and_return(solutions)
        expect(doc_hash[:title_245a_search]).to eq nil
      end
    end

    context 'title_245a_display' do
      let(:sparql_conn) { double('sparql client') }
      before(:each) do
        allow(isd).to receive(:sparql).and_return(sparql_conn)
      end
      it 'is a String (not an Array - single valued Solr field' do
        solutions << RDF::Query::Solution.new(p: 'bf:mainTitle', o: 'foo')
        expect(sparql_conn).to receive(:query).and_return(solutions)
        expect(doc_hash[:title_245a_display]).to be_a String
        expect(doc_hash[:title_245a_display]).to eq 'foo'
      end
      it 'removes trailing punctuation' do
        ['\\', ',', ':', ';', '/'].each do |punct|
          solutions = RDF::Query::Solutions.new
          solutions << RDF::Query::Solution.new(p: 'bf:mainTitle', o: "foo#{punct}")
          expect(sparql_conn).to receive(:query).and_return(solutions)
          allow(isd).to receive(:sparql).and_return(sparql_conn)
          doc_hash = isd.send(:add_doc_title_fields, {})
          expect(doc_hash[:title_245a_display]).to eq 'foo'
        end
        solutions = RDF::Query::Solutions.new
        solutions << RDF::Query::Solution.new(p: 'bf:mainTitle', o: "foo : ")
        expect(sparql_conn).to receive(:query).and_return(solutions)
        allow(isd).to receive(:sparql).and_return(sparql_conn)
        doc_hash = isd.send(:add_doc_title_fields, {})
        expect(doc_hash[:title_245a_display]).to eq 'foo'
      end
      xit 'does not remove trailing period' do
        solutions << RDF::Query::Solution.new(p: 'bf:mainTitle', o: "foo.")
        expect(sparql_conn).to receive(:query).and_return(solutions)
        expect(doc_hash[:title_245a_display]).to eq 'foo.'
        solutions << RDF::Query::Solution.new(p: 'bf:mainTitle', o: "foo Ph.D.")
        expect(sparql_conn).to receive(:query).and_return(solutions)
        allow(isd).to receive(:sparql).and_return(sparql_conn)
        doc_hash = isd.send(:add_doc_title_fields, {})
        expect(doc_hash[:title_245a_display]).to eq 'foo Ph.D.'
      end
      it 'removes leading and trailing whitespace' do
        solutions << RDF::Query::Solution.new(p: 'bf:mainTitle', o: ' foo   ')
        expect(sparql_conn).to receive(:query).and_return(solutions)
        expect(doc_hash[:title_245a_display]).to eq 'foo'
      end
      it 'takes first mainTitle if there are multiple values' do
        solutions << RDF::Query::Solution.new(p: 'bf:mainTitle', o: 'foo')
        solutions << RDF::Query::Solution.new(p: 'bf:mainTitle', o: 'bar')
        expect(sparql_conn).to receive(:query).and_return(solutions)
        expect(doc_hash[:title_245a_display]).to eq 'foo'
      end
      it 'nil if there is no mainTitle' do
        expect(sparql_conn).to receive(:query).and_return(solutions)
        expect(doc_hash[:title_245a_display]).to eq nil
      end
    end
  end

  context '#primary_title_result' do
    it 'sparql connection receives query' do
      sparql_conn = double('sparql client')
      allow(isd).to receive(:sparql).and_return(sparql_conn)
      expect(sparql_conn).to receive(:query)
      isd.send(:primary_title_result)
    end
  end
end
