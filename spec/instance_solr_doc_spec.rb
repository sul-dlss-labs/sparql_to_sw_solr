RSpec.describe SparqlToSwSolr::InstanceSolrDoc do

  let(:instance_uri) { 'http://ld4p-test.stanford.edu/1234567890#Instance' }
  let(:isd) { SparqlToSwSolr::InstanceSolrDoc.new(instance_uri) }

  context '#initialize' do
    it 'assigns @instance_uri as arg' do
      expect(isd.instance_uri).to eq instance_uri
    end
  end

  context '#solr_doc_hash' do
    before do
      allow(isd).to receive(:solr_doc_hash).and_return(id: "666",
                                                       title_245a_search: "Title245aSearch",
                                                       title_245_search: "Title245Search /",
                                                       title_245a_display: "Title245aDisplay",
                                                       title_display: "TitleDisplay",
                                                       title_full_display: "TitleFullDisplay")
    end

    let(:doc_hash) do
      isd.solr_doc_hash
    end
    it 'is a Hash value' do
      expect(doc_hash).to be_a Hash
      expect(doc_hash.size).to be > 0
    end
    it 'assigns an id field with ckey value' do
      allow(isd).to receive(:instance_uri_to_ckey).and_return('666')
      expect(doc_hash[:id].size).to be > 0
      expect(doc_hash[:id]).to eq '666'
    end
    it 'nil if ckey is blacklisted' do
      blacklisted_ckey = '9144273'
      uri = "http://ld4p-test.stanford.edu/#{blacklisted_ckey}#Instance"
      isd = SparqlToSwSolr::InstanceSolrDoc.new(uri)
      expect(isd.solr_doc_hash).to be_nil
    end
  end

  context 'nil instance uri' do
    before do
      allow(isd).to receive(:initialize).and_return(nil)
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

  context '#solution_values' do
    let(:rdfxml) do
      '<?xml version="1.0" encoding="UTF-8"?>
      <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:bf="http://id.loc.gov/ontologies/bibframe/">
        <bf:Instance rdf:about="http://ld4p-test.stanford.edu/1234567890#Instance">
          <bf:title>
            <bf:Title>
              <rdfs:label>label data</rdfs:label>
              <bf:mainTitle>I am a main title</bf:mainTitle>
              <bf:subtitle>subtitle</bf:subtitle>
            </bf:Title>
          </bf:title>
        </bf:Instance>
      </rdf:RDF>'
    end
    let(:g) do
      g = RDF::Graph.new
      rdr = RDF::Reader.for(:rdfxml).new(rdfxml)
      rdr.each { |s| g.insert(s) }
      g
    end

    xit 'retrieves all query solutions of nonVariant titles' do
      solns = isd.send(:solution_values, ['mainTitle'], title_query_str)
      expect(solns.size).to be > 0
      # TODO: need more tests here
    end

    xit 'retrieves solution values as name,value pairs' do
      title_query_str = isd.send(:initialize, :instance_uri)
      solns = isd.send(:solution_values, ['mainTitle'], title_query_str)
      expect(solns.bindings[:p].find { |p| p.to_s == '<http://id.loc.gov/ontologies/bibframe/mainTitle>' }).to_not be_nil
    end

    xit 'retrieves BF2:mainTitle property if it exists' do
      title_query = "
      SELECT ?o WHERE {
        <http://ld4p-test.stanford.edu/10083913#Instance> bf:title ?t .
        ?t bf:mainTitle ?o .
        }"
      sparql_query_obj = SPARQL.parse(title_query)
      solns = sparql_query_obj.execute(g)
      expect(solns.size).to be 1
      expect(solns.first.o).to eq("I am a main title")
    end

    xit 'retrieves BF2:subtitle property if it exists' do
      subtitle_query = "
      PREFIX bf: <http://id.loc.gov/ontologies/bibframe/>
      SELECT ?o WHERE {
        <http://ld4p-test.stanford.edu/10083913#Instance> bf:title ?t .
        ?t bf:subtitle ?o .
        }"
      sparql_query_obj = SPARQL.parse(subtitle_query)
      solns = sparql_query_obj.execute(g)
      expect(solns.first.o).to eq("subtitle")
    end
  end

  context 'data has variant title' do
    let(:rdfxml) do
      '<?xml version="1.0" encoding="UTF-8"?>
      <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:bf="http://id.loc.gov/ontologies/bibframe/">
        <bf:Instance rdf:about="http://ld4p-test.stanford.edu/10083913#Instance">
          <bf:title>
            <bf:Title>
              <rdfs:label>label data</rdfs:label>
              <bf:mainTitle>I am a main title</bf:mainTitle>
              <bf:subtitle>subtitle</bf:subtitle>
            </bf:Title>
          </bf:title>
          <bf:title>
            <bf:Title>
              <rdf:type rdf:resource="http://id.loc.gov/ontologies/bibframe/VariantTitle"/>
              <rdfs:label>variant title label</rdfs:label>
              <bf:mainTitle>variant main title</bf:mainTitle>
              <bf:subtitle>variant subtitle</bf:subtitle>
            </bf:Title>
          </bf:title>
          <bf:title>
            <bf:Title>
              <rdf:type rdf:resource="http://id.loc.gov/ontologies/bibframe/KeyTitle"/>
              <rdfs:label>key title label</rdfs:label>
              <bf:mainTitle>key main title</bf:mainTitle>
              <bf:subtitle>key subtitle</bf:subtitle>
            </bf:Title>
          </bf:title>
        </bf:Instance>
      </rdf:RDF>'
    end
    let(:g) do
      g = RDF::Graph.new
      rdr = RDF::Reader.for(:rdfxml).new(rdfxml)
      rdr.each { |s| g.insert(s) }
      g
    end

    it 'ignores BF2:VariantTitle' do
      skip "rdfs:subClassOf not working as expected"
    end

    # TODO: when we are working against a real graph with loaded ontology file
    it 'mainTitle ignores BF2:VariantTitle and its subclasses' do
      skip "rdfs:subClassOf not working as expected"
      title_query = "PREFIX bf: <http://id.loc.gov/ontologies/bibframe/>
      SELECT ?o WHERE {
        <http://ld4p-test.stanford.edu/10083913#Instance> bf:title ?t .
        ?t bf:mainTitle ?o .
        filter not exists { ?t a bf:VariantTitle ;
          rdfs:subClassOf bf:VariantTitle }
        }"
      sparql_query_obj = SPARQL.parse(title_query)
      solns = sparql_query_obj.execute(g)
      expect(solns.size).to be 1
      expect(solns.first.o).to eq("I am a main title")
    end

    it 'subtitle ignores BF2:VariantTitle' do
      skip "rdfs:subClassOf not working as expected"
      #   filter not exists { ?t rdfs:subClassOf bf:VariantTitle }
      # }"
      #  filter not exists { ?t a bf:VariantTitle }
      # filter not exists { ?t a bf:VariantTitle ;
      #   rdfs:subClassOf bf:VariantTitle }

      # create SPARQL query object from query
      sq = SPARQL.parse(title_query)

      # run the query against the graph and compare results
      solns = sq.execute(g)
      expect(solns.size).to eq 1
      expect(solns.first.o).to eq("I am a main title")
    end
  end
end
