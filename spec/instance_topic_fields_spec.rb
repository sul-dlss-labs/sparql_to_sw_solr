RSpec.describe SparqlToSwSolr::InstanceSolrDoc::InstanceTopicFields do

  let(:instance_uri) { 'http://ld4p-test.stanford.edu/1234567890#Instance' }
  let(:isd) { SparqlToSwSolr::InstanceSolrDoc.new(instance_uri) }

  context 'SPARQL' do
    let(:sparql_conn) { double('sparql client') }
    let(:solutions) { RDF::Query::Solutions.new }

    before(:each) do
      allow(isd).to receive(:sparql).and_return(sparql_conn)
      expect(sparql_conn).to receive(:query).and_return(solutions)
    end

    shared_examples 'it_indexes_topics' do
      # examples calling this shared_examples must declare `let` for:
      # :solr_field
      let(:doc_hash) { isd.send(:add_doc_topic_fields, {}) }
      let(:solr_topics) { doc_hash[solr_field] }
      let(:bf_topics) { ['math', 'physics'] }

      it 'empty Array when there are no topics' do
        expect(solr_topics).to be_an Array
        expect(solr_topics).to be_empty
      end
      it 'is an Array - multi-valued Solr field - when there is one topic' do
        solutions << RDF::Query::Solution.new(p: 'madsrdf:authoritativeLabel', topicLabel: bf_topics.first)
        expect(solr_topics).to be_an Array
        expect(solr_topics).to include bf_topics.first
      end
      it 'is an Array - multi-valued Solr field - when there are multiple topics' do
        solutions << RDF::Query::Solution.new(p: 'madsrdf:authoritativeLabel', topicLabel: bf_topics.first)
        solutions << RDF::Query::Solution.new(p: 'madsrdf:authoritativeLabel', topicLabel: bf_topics.last)
        expect(solr_topics).to be_an Array
        expect(solr_topics).to include bf_topics.first
        expect(solr_topics).to include bf_topics.last
      end
      it 'strips everything after a "--" and trailing punctuation and whitespace' do
        bf_topic = 'abc. -- def ;.  '
        bf_topic_parsed = 'abc'
        solutions << RDF::Query::Solution.new(p: 'madsrdf:authoritativeLabel', topicLabel: bf_topic)
        expect(solr_topics).to be_an Array
        expect(solr_topics).to include bf_topic_parsed
      end
      it 'strips only trailing punctuation and whitespace (not all punctuation)' do
        bf_topic = 'abc, def .  ; , !   '
        bf_topic_parsed = 'abc, def'
        solutions << RDF::Query::Solution.new(p: 'madsrdf:authoritativeLabel', topicLabel: bf_topic)
        expect(solr_topics).to be_an Array
        expect(solr_topics).to include bf_topic_parsed
      end
    end

    context 'topic_facet' do
      let(:solr_field) { :topic_facet }
      it_behaves_like 'it_indexes_topics'
    end

    context 'topic_search' do
      let(:solr_field) { :topic_search }
      it_behaves_like 'it_indexes_topics'
    end

    context '#topics' do
      it 'sparql connection receives query' do
        isd.send(:topics)
      end
    end
  end
end
