RSpec.describe SparqlToSwSolr::InstanceSolrDoc::TopicFields do

  let(:instance_uri) { 'http://ld4p-test.stanford.edu/1234567890#Instance' }
  let(:isd) { SparqlToSwSolr::InstanceSolrDoc.new(instance_uri) }
  let(:doc_hash) { isd.send(:add_doc_topic_fields, {}) }

  context 'SPARQL' do
    let(:sparql_conn) { double('sparql client') }
    let(:solutions) { RDF::Query::Solutions.new }

    before(:each) do
      allow(isd).to receive(:sparql).and_return(sparql_conn)
      expect(sparql_conn).to receive(:query).and_return(solutions)
    end

    shared_examples 'it_indexes_topics' do
      # examples calling this shared_examples must declare:
      # let(:solr_topics) { doc_hash[:some_topic_field] }

      # These simple topic strings require no parsing; more complex
      # topic strings are used in specs that require parsing.
      let(:bf_topics) { ['math', 'physics'] }

      it 'empty Array when there are no topics' do
        expect(solr_topics).to be_an Array
        expect(solr_topics).to be_empty
      end
      it 'is an Array - multi-valued Solr field - when there is one topic' do
        solutions << RDF::Query::Solution.new(p: 'madsrdf:authoritativeLabel', topicLabel: bf_topics.first)
        expect(solr_topics).to be_an Array
        expect(solr_topics).to eq [bf_topics.first]
      end
      it 'is an Array - multi-valued Solr field - when there are multiple topics' do
        bf_topics.each do |bf_topic|
          solutions << RDF::Query::Solution.new(p: 'madsrdf:authoritativeLabel', topicLabel: bf_topic)
        end
        expect(solr_topics).to be_an Array
        expect(solr_topics).to eq bf_topics
      end
    end

    context 'topic_search' do
      let(:solr_topics) { doc_hash[:topic_search] }
      it_behaves_like 'it_indexes_topics'
      it 'preserves the entire topic string, including "--", but not trailing punctuation and whitespace' do
        bf_topic = 'abc. -- def ;.  '
        solr_topic = 'abc. -- def'
        solutions << RDF::Query::Solution.new(p: 'madsrdf:authoritativeLabel', topicLabel: bf_topic)
        expect(solr_topics).to be_an Array
        expect(solr_topics).to include solr_topic
      end
    end

    context 'topic_facet' do
      let(:solr_topics) { doc_hash[:topic_facet] }
      it_behaves_like 'it_indexes_topics'

      def check_parsers(bf_topic, solr_topic)
        solutions << RDF::Query::Solution.new(p: 'madsrdf:authoritativeLabel', topicLabel: bf_topic)
        expect(solr_topics).to be_an Array
        expect(solr_topics).to eq [solr_topic]
      end

      it 'strips everything after a "--" and trailing punctuation and whitespace' do
        check_parsers('abc. -- def ;.  ', 'abc')
      end
      it 'strips only trailing punctuation and whitespace (not all punctuation)' do
        check_parsers('abc, def .  ; , !   ', 'abc, def')
      end
      it 'correctly parses a real example' do
        check_parsers('Conductors (Music)--Italy--Biography', 'Conductors (Music)')
      end
      it 'allows punctuation for latin abbreviation: etc.' do
        # consider others, but not all of them, e.g.
        # https://en.wikipedia.org/wiki/List_of_Latin_abbreviations
        check_parsers(
          'Comic books, strips, etc.--United States--History and criticism, Combat in art, Combat in literature',
          'Comic books, strips, etc.'
        )
      end
    end

    context '#topics' do
      it 'sparql connection receives query' do
        isd.send(:topics)
      end
    end
  end
end
