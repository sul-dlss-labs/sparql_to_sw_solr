RSpec.describe SparqlToSwSolr::InstanceSolrDoc do

  let(:instance_uri) { 'http://ld4p-test.stanford.edu/1234567890#Instance' }
  let(:isd) { SparqlToSwSolr::InstanceSolrDoc.new(instance_uri) }

  context '#initialize' do
    it 'assigns @instance_uri as arg' do
      expect(isd.instance_uri).to eq instance_uri
    end
  end

  context '.instance_uri_to_ckey' do
    it 'returns the ckey portion of instance_uri from marc2bibframe2 converter' do
      expect(SparqlToSwSolr::InstanceSolrDoc.instance_uri_to_ckey(instance_uri)).to eq '1234567890'

      i_uri = 'http://ld4p-test.stanford.edu/666#Instance'
      expect(SparqlToSwSolr::InstanceSolrDoc.instance_uri_to_ckey(i_uri)).to eq '666'
    end
    it 'false if non-numeric ckey' do
      i_uri = 'http://ld4p-test.stanford.edu/foo#Instance'
      expect(SparqlToSwSolr::InstanceSolrDoc.instance_uri_to_ckey(i_uri)).to eq false
    end
  end

  context '#init_doc' do
    let(:doc_hash) { isd.send(:init_doc) }

    it 'assigns an id field with ckey value' do
      allow(isd).to receive(:instance_uri_to_ckey).and_return('666')
      expect(doc_hash[:id]).to eq '666'
    end
    it 'assigns Book value (hardcoded for now) to format_main_ssim' do
      allow(isd).to receive(:instance_uri_to_ckey).and_return('666')
      expect(doc_hash[:format_main_ssim]).to eq 'Book'
    end
    it 'assigns DOC_SOURCE to access_facet' do
      expect(doc_hash.keys).to include(:access_facet)
      expect(doc_hash[:access_facet]).to eq(SparqlToSwSolr::InstanceSolrDoc::DOC_SOURCE)
    end
    it 'assigns DOC_SOURCE to collection' do
      expect(doc_hash.keys).to include(:collection)
      expect(doc_hash[:collection]).to eq(SparqlToSwSolr::InstanceSolrDoc::DOC_SOURCE)
    end
  end

  context '#solr_doc_hash' do
    let(:doc_hash) { isd.solr_doc_hash }

    before(:each) do
      sparql_conn = double('sparql client', query: RDF::Query::Solutions.new)
      allow(isd).to receive(:sparql).and_return(sparql_conn)
    end

    it 'nil if false from #instance_uri_to_ckey' do
      allow(isd).to receive(:instance_uri_to_ckey).and_return(false)
      expect(doc_hash).to be_nil
    end
    it 'nil if ckey is blacklisted' do
      blacklisted_ckey = '9144273'
      uri = "http://ld4p-test.stanford.edu/#{blacklisted_ckey}#Instance"
      isd = SparqlToSwSolr::InstanceSolrDoc.new(uri)
      expect(isd.solr_doc_hash).to be_nil
    end
    it 'is a Hash value' do
      expect(doc_hash).to be_a Hash
      expect(doc_hash.size).to be > 0
    end

    context 'includes field(s) for' do
      it 'titles' do
        expect(isd).to receive(:add_title_fields)
        isd.solr_doc_hash
      end
      it 'topics' do
        expect(isd).to receive(:add_topic_fields)
        isd.solr_doc_hash
      end
      it 'language' do
        lang_value = ['Italian', 'Chinese', 'Spanish']
        expect(isd).to receive(:language_values).and_return(lang_value)
        expect(doc_hash).to include(language: lang_value)
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
