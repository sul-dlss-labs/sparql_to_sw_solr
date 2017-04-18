RSpec.describe SparqlToSwSolr::InstanceSolrDoc::InstanceStdNumFields do

  let(:instance_uri) { 'http://ld4p-test.stanford.edu/1234567890#Instance' }
  let(:isd) { SparqlToSwSolr::InstanceSolrDoc.new(instance_uri) }
  let(:sparql_conn) { double('sparql client') }
  let(:solutions) { RDF::Query::Solutions.new }
  let(:doc_hash) { isd.send(:add_std_num_fields, {}) }

  before(:each) do
    allow(isd).to receive(:sparql).and_return(sparql_conn)
    allow(sparql_conn).to receive(:query).and_return(solutions)
  end

  context '#add_std_num_fields' do
    it 'includes oclc field' do
      expect(isd).to receive(:oclc_nums)
      isd.solr_doc_hash
    end
  end

  context '#oclc_nums' do
    let(:ocolc_m) { 'mmmmm' }
    let(:ocolc) { 'plain' }
    let(:ocm) { 'ocm12345678' }
    let(:ocn) { 'ocn123456789' }

    it 'OCoLC-M values if they exist' do
      solutions << RDF::Query::Solution.new(value: ocolc_m, label: 'OCoLC-M')
      expect(isd.send(:oclc_nums)).to eq [ocolc_m]
    end
    it 'OCoLC-M values only if there are both OCoLC-M and OCoLC values' do
      solutions << RDF::Query::Solution.new(value: ocolc, label: 'OCoLC')
      solutions << RDF::Query::Solution.new(value: ocolc_m, label: 'OCoLC-M')
      expect(isd.send(:oclc_nums)).to eq [ocolc_m]
    end
    it 'OCoLC values if they exist and no OCoLC-M values' do
      solutions << RDF::Query::Solution.new(value: ocolc, label: 'OCoLC')
      expect(isd.send(:oclc_nums)).to eq [ocolc]
    end
    it 'empty Array when no OCoLC-M or OCoLC values' do
      expect(isd.send(:oclc_nums)).to eq []
    end
    it 'no value included when label is nil and value starts "ocm"' do
      solutions << RDF::Query::Solution.new(value: ocm)
      expect(isd.send(:oclc_nums)).to eq []
    end
    it 'no value included when label is nil and value starts "ocn"' do
      solutions << RDF::Query::Solution.new(value: ocn)
      expect(isd.send(:oclc_nums)).to eq []
    end
    it 'no value included when label is nil and value starts "on"' do
      solutions << RDF::Query::Solution.new(value: 'on12343')
      expect(isd.send(:oclc_nums)).to eq []
    end
    it 'no value included when label is something else' do
      solutions << RDF::Query::Solution.new(value: ocolc, label: 'not_it')
      expect(isd.send(:oclc_nums)).to eq []
    end
    it 'is multivalued when there are multiple values of one type' do
      solutions << RDF::Query::Solution.new(value: ocolc_m, label: 'OCoLC-M')
      solutions << RDF::Query::Solution.new(value: '666', label: 'OCoLC-M')
      expect(isd.send(:oclc_nums)).to eq [ocolc_m, '666']
      solutions = RDF::Query::Solutions.new
      solutions << RDF::Query::Solution.new(value: ocolc, label: 'OCoLC')
      solutions << RDF::Query::Solution.new(value: '333', label: 'OCoLC')
      allow(sparql_conn).to receive(:query).and_return(solutions)
      expect(isd.send(:oclc_nums)).to eq [ocolc, '333']
    end
  end

end
