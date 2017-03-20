RSpec.describe SparqlToSwSolr::InstanceSolrDoc do

  let(:instance_uri) { 'http://ld4p-test.stanford.edu/1234567890#Instance' }
  let(:isd) { SparqlToSwSolr::InstanceSolrDoc.new(instance_uri) }

  context '#initialize' do
    it 'assigns @instance_uri as arg' do
      expect(isd.instance_uri).to eq instance_uri
    end
  end

  context '#assemble_doc' do
    let(:doc_hash) do
      isd.assemble_doc
      isd.solr_doc_hash
    end
    it 'assigns a hash value to @solr_doc_hash' do
      expect(doc_hash).to be_a Hash
      expect(doc_hash.size).to be > 0
    end
    it 'assigns an id field with ckey value' do
      expect(isd).to receive(:instance_uri_to_ckey).and_return('foo')
      expect(doc_hash[:id].size).to be > 0
      expect(doc_hash[:id]).to eq 'foo'
    end
  end

  context '#instance_uri_to_ckey' do
    it 'returns a non-null String' do
      expect(isd.send(:instance_uri_to_ckey)).to eq '1234567890'
      skip 'TODO: to be implemented'
    end
    # TODO: what if there is no ckey in instance uri?
  end
end
