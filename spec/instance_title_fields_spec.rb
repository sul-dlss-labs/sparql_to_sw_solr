RSpec.describe SparqlToSwSolr::InstanceSolrDoc::InstanceTitleFields do

  let(:instance_uri) { 'http://ld4p-test.stanford.edu/1234567890#Instance' }
  let(:isd) { SparqlToSwSolr::InstanceSolrDoc.new(instance_uri) }

  it 'instance_uri has a value in the context of InstanceTitleFields module' do
    expect(isd.instance_uri).to eq instance_uri
  end

  context 'add_title_fields' do
    let(:doc_hash) { isd.send(:add_title_fields, {}) }
    let(:solutions) { RDF::Query::Solutions.new }

    context 'title_245a_search' do
      let(:sparql_conn) { double('sparql client') }
      before(:each) do
        allow(isd).to receive(:sparql).and_return(sparql_conn)
      end
      it 'is a mainTitle String (not an Array - single valued Solr field)' do
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
      it 'is a mainTitle String (not an Array - single valued Solr field)' do
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
          doc_hash = isd.send(:add_title_fields, {})
          expect(doc_hash[:title_245a_display]).to eq 'foo'
        end
      end
      it 'removes combinations of trailing punct and spaces' do
        solutions << RDF::Query::Solution.new(p: 'bf:mainTitle', o: "foo : ")
        expect(sparql_conn).to receive(:query).and_return(solutions)
        allow(isd).to receive(:sparql).and_return(sparql_conn)
        doc_hash = isd.send(:add_title_fields, {})
        expect(doc_hash[:title_245a_display]).to eq 'foo'
      end
      it 'does not remove trailing period' do
        solutions << RDF::Query::Solution.new(p: 'bf:mainTitle', o: "foo.")
        expect(sparql_conn).to receive(:query).and_return(solutions)
        expect(doc_hash[:title_245a_display]).to eq 'foo.'
        solutions = RDF::Query::Solutions.new
        solutions << RDF::Query::Solution.new(p: 'bf:mainTitle', o: "foo Ph.D.")
        expect(sparql_conn).to receive(:query).and_return(solutions)
        allow(isd).to receive(:sparql).and_return(sparql_conn)
        doc_hash = isd.send(:add_title_fields, {})
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

    context 'title_245_search' do
      let(:sparql_conn) { double('sparql client') }
      before(:each) do
        allow(isd).to receive(:sparql).and_return(sparql_conn)
      end
      it 'is a rdfs:label String (not an Array - single valued Solr field)' do
        solutions << RDF::Query::Solution.new(p: 'rdf-schema#label', o: 'foo')
        expect(sparql_conn).to receive(:query).and_return(solutions)
        expect(doc_hash[:title_245_search]).to be_a String
        expect(doc_hash[:title_245_search]).to eq 'foo'
      end
      it 'takes first label if there are multiple values' do
        solutions << RDF::Query::Solution.new(p: 'rdf-schema#label', o: 'foo')
        solutions << RDF::Query::Solution.new(p: 'rdf-schema#label', o: 'bar')
        expect(sparql_conn).to receive(:query).and_return(solutions)
        expect(doc_hash[:title_245_search]).to eq 'foo'
      end
      it 'nil if there is no label' do
        expect(sparql_conn).to receive(:query).and_return(solutions)
        expect(doc_hash[:title_245_search]).to eq nil
      end
    end

    context 'title_display' do
      let(:sparql_conn) { double('sparql client') }
      before(:each) do
        allow(isd).to receive(:sparql).and_return(sparql_conn)
      end
      it 'is a String concatenation of mainTitle + subtitle' do
        solutions << RDF::Query::Solution.new(p: 'mainTitle', o: 'foo')
        solutions << RDF::Query::Solution.new(p: 'subtitle', o: 'bar')
        expect(sparql_conn).to receive(:query).and_return(solutions)
        expect(doc_hash[:title_display]).to be_a String
        expect(doc_hash[:title_display]).to eq 'foo : bar'
      end
      it 'takes first mainTitle value if there are multiple values for mainTitle' do
        solutions << RDF::Query::Solution.new(p: 'mainTitle', o: 'foo')
        solutions << RDF::Query::Solution.new(p: 'mainTitle', o: 'goo')
        solutions << RDF::Query::Solution.new(p: 'subtitle', o: 'bar')
        expect(sparql_conn).to receive(:query).and_return(solutions)
        expect(doc_hash[:title_display]).to eq 'foo : bar'
      end
      it 'does not include separator if there is no subtitle' do
        solutions << RDF::Query::Solution.new(p: 'mainTitle', o: 'foo')
        expect(sparql_conn).to receive(:query).and_return(solutions)
        expect(doc_hash[:title_display]).to eq 'foo'
      end
      it 'includes only the subtitle without separator if there is no mainTitle' do
        solutions << RDF::Query::Solution.new(p: 'subtitle', o: 'bar')
        expect(sparql_conn).to receive(:query).and_return(solutions)
        expect(doc_hash[:title_display]).to eq 'bar'
      end
      it 'empty if no mainTitle or subtitle value' do
        expect(sparql_conn).to receive(:query).and_return(solutions)
        expect(doc_hash[:title_display]).to be_empty
      end
      it 'removes trailing punctuation' do
        ['\\', ',', ':', ';', '/'].each do |punct|
          solutions = RDF::Query::Solutions.new
          solutions << RDF::Query::Solution.new(p: 'mainTitle', o: "foo#{punct}")
          solutions << RDF::Query::Solution.new(p: 'subtitle', o: 'bar /')
          expect(sparql_conn).to receive(:query).and_return(solutions)
          allow(isd).to receive(:sparql).and_return(sparql_conn)
          doc_hash = isd.send(:add_title_fields, {})
          expect(doc_hash[:title_display]).to eq 'foo : bar'
        end
      end
      it 'removes combinations of trailing punct and spaces' do
        solutions << RDF::Query::Solution.new(p: 'bf:mainTitle', o: "foo : ")
        solutions << RDF::Query::Solution.new(p: 'subtitle', o: 'bar / ')
        expect(sparql_conn).to receive(:query).and_return(solutions)
        allow(isd).to receive(:sparql).and_return(sparql_conn)
        doc_hash = isd.send(:add_title_fields, {})
        expect(doc_hash[:title_display]).to eq 'foo : bar'
      end
    end

    context 'title_full_display' do
      let(:sparql_conn) { double('sparql client') }
      before(:each) do
        allow(isd).to receive(:sparql).and_return(sparql_conn)
      end
      context 'no responsibility statement' do
        it 'is the same as title_display String' do
          solutions << RDF::Query::Solution.new(p: 'mainTitle', o: 'foo')
          solutions << RDF::Query::Solution.new(p: 'subtitle', o: 'bar')
          expect(sparql_conn).to receive(:query).and_return(solutions)
          title_display = doc_hash[:title_display]
          expect(doc_hash[:title_full_display]).to eq(title_display)
        end
        it 'takes title_display value if there are multiple values for mainTitle' do
          solutions << RDF::Query::Solution.new(p: 'mainTitle', o: 'foo')
          solutions << RDF::Query::Solution.new(p: 'mainTitle', o: 'goo')
          solutions << RDF::Query::Solution.new(p: 'subtitle', o: 'bar')
          expect(sparql_conn).to receive(:query).and_return(solutions)
          title_display = doc_hash[:title_display]
          expect(doc_hash[:title_full_display]).to eq(title_display)
        end
        it 'is empty if no title_display value' do
          expect(sparql_conn).to receive(:query).and_return(solutions)
          expect(doc_hash[:title_full_display]).to be_empty
        end
      end

      context 'responsibility statement' do
        it 'shows just plain title_display value if responsibility statement exists but is empty' do
          solutions << RDF::Query::Solution.new(p: 'mainTitle', o: 'foo')
          solutions << RDF::Query::Solution.new(p: 'subtitle', o: 'bar')
          solutions << RDF::Query::Solution.new(p: 'responsibilityStatement', o: '')
          expect(sparql_conn).to receive(:query).and_return(solutions)
          title_display = doc_hash[:title_display]
          expect(doc_hash[:title_full_display]).to eq(title_display)
        end
        it 'responsibility statement comes from bf:responsibilityStatement property' do
          solutions << RDF::Query::Solution.new(p: 'bf:responsibilityStatement', o: 'roo')
          expect(isd.send(:values_from_solutions, solutions, 'responsibilityStatement')).to eq ['roo']
        end
        it 'concatenates resp statement to title_display value with / separator' do
          solutions << RDF::Query::Solution.new(p: 'mainTitle', o: 'foo')
          solutions << RDF::Query::Solution.new(p: 'responsibilityStatement', o: 'roo')
          expect(sparql_conn).to receive(:query).and_return(solutions)
          expect(doc_hash[:title_full_display]).to include('/')
        end
        it 'takes first resp statement if there are multiple values for it' do
          solutions << RDF::Query::Solution.new(p: 'mainTitle', o: 'foo')
          solutions << RDF::Query::Solution.new(p: 'responsibilityStatement', o: 'roo')
          solutions << RDF::Query::Solution.new(p: 'responsibilityStatement', o: 'too')
          expect(sparql_conn).to receive(:query).and_return(solutions)
          expect(doc_hash[:title_full_display]).to eq('foo / roo')
        end
        it 'removes trailing punct from responsiblity statement' do
          ['\\', ',', ':', ';', '/'].each do |punct|
            solutions << RDF::Query::Solution.new(p: 'mainTitle', o: 'foo')
            solutions << RDF::Query::Solution.new(p: 'responsibilityStatement', o: "roo#{punct}")
            expect(sparql_conn).to receive(:query).and_return(solutions)
            allow(isd).to receive(:sparql).and_return(sparql_conn)
            doc_hash = isd.send(:add_title_fields, {})
            expect(doc_hash[:title_full_display]).to eq 'foo / roo'
          end
        end
        it 'removes comb of trailing punct and spaces from resp statement' do
          solutions << RDF::Query::Solution.new(p: 'mainTitle', o: 'foo')
          solutions << RDF::Query::Solution.new(p: 'responsibilityStatement', o: "roo : ")
          expect(sparql_conn).to receive(:query).and_return(solutions)
          allow(isd).to receive(:sparql).and_return(sparql_conn)
          doc_hash = isd.send(:add_title_fields, {})
          expect(doc_hash[:title_full_display]).to eq 'foo / roo'
        end
      end

      context 'no title_display' do
        it 'is empty if no title_display or resp statement' do
          expect(sparql_conn).to receive(:query).and_return(solutions)
          expect(doc_hash[:title_display]).to be_empty
          expect(doc_hash[:title_full_display]).to be_empty
        end
        it 'responsibility statement without prefix separator if no title_display value' do
          expect(sparql_conn).to receive(:query).and_return(solutions)
          solutions << RDF::Query::Solution.new(p: 'responsibilityStatement', o: 'roo')
          allow(isd).to receive(:sparql).and_return(sparql_conn)
          expect(doc_hash[:title_display]).to be_empty
          expect(doc_hash[:title_full_display]).to eq 'roo'
        end
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

  context '#values_from_solutions' do
    let(:solutions) do
      solutions = RDF::Query::Solutions.new
      solutions << RDF::Query::Solution.new(p: 'bf:mainTitle', o: 'foo')
      solutions << RDF::Query::Solution.new(p: 'bf:mainTitle', o: 'bar')
    end
    it 'returns array of values for passed predicate name (matching using endsWith (ignoring namespace))' do
      expect(isd.send(:values_from_solutions, solutions, 'bf:mainTitle')).to eq ['foo', 'bar']
      expect(isd.send(:values_from_solutions, solutions, 'mainTitle')).to eq ['foo', 'bar']
    end
    it 'returns empty array if no matching predicate name' do
      expect(isd.send(:values_from_solutions, solutions, 'zzzzz')).to eq []
    end
  end

end
