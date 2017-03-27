RSpec.describe SparqlToSwSolr::InstanceSolrDoc do

  let(:instance_uri) { 'http://ld4p-test.stanford.edu/1234567890#Instance' }
  let(:isd) { SparqlToSwSolr::InstanceSolrDoc.new(instance_uri) }

  context '#initialize' do
    it 'assigns @instance_uri as arg' do
      expect(isd.instance_uri).to eq instance_uri
    end
  end

  context '#solr_doc_hash' do
    let(:doc_hash) do
      isd.solr_doc_hash
    end
    it 'is a Hash value' do
      expect(doc_hash).to be_a Hash
      expect(doc_hash.size).to be > 0
    end
    it 'assigns an id field with ckey value' do
      expect(isd).to receive(:instance_uri_to_ckey).and_return('666').twice
      expect(doc_hash[:id].size).to be > 0
      expect(doc_hash[:id]).to eq '666'
    end
    it 'nil if false from #instance_uri_to_ckey' do
      expect(isd).to receive(:instance_uri_to_ckey).and_return(false)
      expect(isd.solr_doc_hash).to be_nil
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
end
