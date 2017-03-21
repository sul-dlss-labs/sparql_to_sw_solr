require 'rsolr'

RSpec.describe SparqlToSwSolr::SolrService do

  let(:ss) { SparqlToSwSolr::SolrService.new }

  let(:expected_conn_opts) do
    {
      read_timeout: SparqlToSwSolr::SolrService::READ_TIMEOUT,
      open_timeout: SparqlToSwSolr::SolrService::OPEN_TIMEOUT,
      url: SparqlToSwSolr::SolrService::SOLR_URL,
      retry_503: SparqlToSwSolr::SolrService::NUM_TIMES_RETRY_503
    }
  end

  context '#initialize' do
    it 'sets @conn_options value' do
      opts = ss.instance_variable_get(:@conn_options)
      expect(opts.size).to eq 4
      expect(opts).to include(expected_conn_opts)
    end
  end

  context '#add_one_doc' do
    it 'calls add with commitWithin param' do
      doc_hash = { foo: 'bar' }
      expected_opts = { add_attributes: { commitWithin: SparqlToSwSolr::SolrService::COMMIT_WITHIN } }
      expect(ss.send(:conn)).to receive(:add).with(doc_hash, expected_opts)
      ss.add_one_doc(doc_hash)
    end
  end

  context '#delete_by_id' do
    it 'is delegated to conn' do
      expect(ss.send(:conn)).to receive(:delete_by_id).with('666')
      ss.delete_by_id('666')
    end
  end

  context '#conn' do
    it 'calls RSolr.connect with @conn_options if @conn = nil' do
      expect(RSolr).to receive(:connect).with(hash_including(expected_conn_opts))
      ss.send(:conn)
    end
  end
end
