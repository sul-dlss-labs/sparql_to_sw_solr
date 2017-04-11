RSpec.describe SparqlToSwSolr::InstanceSolrDoc::InstancePubFields do

  let(:instance_uri) { 'http://ld4p-test.stanford.edu/1234567890#Instance' }
  let(:isd) { SparqlToSwSolr::InstanceSolrDoc.new(instance_uri) }
  let(:sparql_conn) { double('sparql client') }
  let(:solutions) { RDF::Query::Solutions.new }
  let(:doc_hash) { isd.send(:add_publication_fields, {}) }

  before(:each) do
    allow(isd).to receive(:sparql).and_return(sparql_conn)
    allow(sparql_conn).to receive(:query).and_return(solutions)
  end

  context '#add_publication_fields' do
    it 'includes pub year fields' do
      expect(isd).to receive(:add_pub_year_fields)
      isd.solr_doc_hash
    end
    it 'includes imprint_display field' do
      expect(isd).to receive(:imprint_display)
      isd.solr_doc_hash
    end
  end

  context '#add_pub_year_fields' do
    shared_examples 'single-valued field' do |solr_field_name|
      let(:values_array) { ['2000', '1090'] }
      let(:solr_field) { doc_hash[solr_field_name] }

      it 'is a String (first value if there are multiple values)' do
        values_array.each do |value|
          solutions << RDF::Query::Solution.new(pub_year: value)
        end
        expect(solr_field).not_to be_an Array
        if solr_field.is_a?(Integer)
          expect(solr_field).to eq values_array.first.to_i
        else
          expect(solr_field).to eq values_array.first
        end
      end

      it 'nil if there is no value' do
        expect(solr_field).to eq nil
      end
    end

    shared_examples 'copes with wacko values' do |solr_field_name|
      # note that these are all values provided by https://github.com/lcnetdev/marc2bibframe2 from our data ...
      ['2014-09', '2015/9999', '2016-1987-87', '2013-09XX-XX'].each do |raw_value|
        it "#{raw_value} becomes #{raw_value[0, 4]}" do
          solutions << RDF::Query::Solution.new(pub_year: raw_value)
          result = doc_hash[solr_field_name]
          if result.is_a?(Integer)
            expect(result).to eq raw_value[0, 4].to_i
          else
            expect(result).to eq raw_value[0, 4]
          end
        end
      end
    end

    # sort fields
    context 'pub_year_isi' do
      # new way (not yet used)
      it_behaves_like 'single-valued field', :pub_year_isi
      it_behaves_like 'copes with wacko values', :pub_year_isi
    end
    context 'pub_date_sort' do
      # old way, used in SW, but to be replaced by pub_year_isi
      it_behaves_like 'single-valued field', :pub_date_sort
      it_behaves_like 'copes with wacko values', :pub_date_sort
    end
    # display fields
    context 'pub_year_ss' do
      # new way (used for mods)
      it_behaves_like 'single-valued field', :pub_year_ss
      it_behaves_like 'copes with wacko values', :pub_year_ss
    end
    context 'pub_date' do
      # old way, for display string ??  replaced by specific ones?
      it_behaves_like 'single-valued field', :pub_date
      it_behaves_like 'copes with wacko values', :pub_date
    end
    context 'publication_year_isi' do
      it_behaves_like 'single-valued field', :publication_year_isi
      it_behaves_like 'copes with wacko values', :publication_year_isi
    end

    # date slider
    context 'pub_year_tisim' do
      # NOTE: single valued for now
      it_behaves_like 'single-valued field', :pub_year_tisim
      it_behaves_like 'copes with wacko values', :pub_year_tisim
    end
  end

  context '#imprint_display' do
    let(:edition_val) { 'first edition' }
    let(:pub_info) { 'place : agent, year.' }
    let(:manu_place) { 'manu_place' }
    let(:manu_agent) { 'manu_agent' }
    let(:manu_date) { '1990' }

    it 'gets edition info from bf:editionStatement' do
      expect(sparql_conn).to receive(:query).with(a_string_matching('editionStatement')).and_return(solutions)
      isd.send(:edition_solns)
    end
    it 'gets publication information from bf:provisionActivityStatement' do
      expect(sparql_conn).to receive(:query).with(a_string_matching('provisionActivityStatement')).and_return(solutions)
      isd.send(:publication_solns)
    end
    it 'gets manufacture information from bf:provisionActivity of type bf:Manufacture' do
      expect(sparql_conn).to receive(:query).with(a_string_matching('provisionActivity ')).and_return(solutions)
      isd.send(:manufacture_solns)
    end
    it 'concatenates edition, publication and manufacture information' do
      ed_solns = RDF::Query::Solutions.new
      ed_solns << RDF::Query::Solution.new(edition: edition_val)
      expect(isd).to receive(:edition_solns).and_return(ed_solns)
      pub_solns = RDF::Query::Solutions.new
      pub_solns << RDF::Query::Solution.new(pub_info: pub_info)
      expect(isd).to receive(:publication_solns).and_return(pub_solns)
      manu_solns = RDF::Query::Solutions.new
      manu_solns << RDF::Query::Solution.new(manu_place: manu_place, manu_agent: manu_agent, manu_date: manu_date)
      expect(isd).to receive(:manufacture_solns).and_return(manu_solns)
      exp_val = "#{edition_val} - #{pub_info}. #{manu_place} : #{manu_agent}, #{manu_date}"
      expect(isd.send(:imprint_display)).to eq exp_val
    end
    it 'is nil if there is no value for edition, publication or manufacture' do
      expect(isd.send(:imprint_display)).to be nil
    end
    it 'publication + manufacture if no edition info' do
      pub_solns = RDF::Query::Solutions.new
      pub_solns << RDF::Query::Solution.new(pub_info: pub_info)
      expect(isd).to receive(:publication_solns).and_return(pub_solns)
      manu_solns = RDF::Query::Solutions.new
      manu_solns << RDF::Query::Solution.new(manu_place: manu_place, manu_agent: manu_agent, manu_date: manu_date)
      expect(isd).to receive(:manufacture_solns).and_return(manu_solns)
      expect(isd.send(:imprint_display)).to eq "#{pub_info}. #{manu_place} : #{manu_agent}, #{manu_date}"
    end
    it 'edition + manufacture if no publication info' do
      ed_solns = RDF::Query::Solutions.new
      ed_solns << RDF::Query::Solution.new(edition: edition_val)
      expect(isd).to receive(:edition_solns).and_return(ed_solns)
      manu_solns = RDF::Query::Solutions.new
      manu_solns << RDF::Query::Solution.new(manu_place: manu_place, manu_agent: manu_agent, manu_date: manu_date)
      expect(isd).to receive(:manufacture_solns).and_return(manu_solns)
      expect(isd.send(:imprint_display)).to eq "#{edition_val} - #{manu_place} : #{manu_agent}, #{manu_date}"
    end
    it 'edition + publication if no manufacture info' do
      ed_solns = RDF::Query::Solutions.new
      ed_solns << RDF::Query::Solution.new(edition: edition_val)
      expect(isd).to receive(:edition_solns).and_return(ed_solns)
      pub_solns = RDF::Query::Solutions.new
      pub_solns << RDF::Query::Solution.new(pub_info: pub_info)
      expect(isd).to receive(:publication_solns).and_return(pub_solns)
      expect(isd.send(:imprint_display)).to eq "#{edition_val} - #{pub_info}"
    end
    it 'edition info if no publication or manufacture info' do
      solutions << RDF::Query::Solution.new(edition: edition_val)
      expect(isd.send(:imprint_display)).to eq edition_val
    end
    it 'publication info if no edition or manufacture info' do
      solutions << RDF::Query::Solution.new(pub_info: pub_info)
      expect(isd.send(:imprint_display)).to eq pub_info
    end
    it 'manufacture info if no edition or publication info' do
      solutions << RDF::Query::Solution.new(manu_place: manu_place, manu_agent: manu_agent, manu_date: manu_date)
      expect(isd.send(:imprint_display)).to eq "#{manu_place} : #{manu_agent}, #{manu_date}"
    end
    it 'uses first editionStatement if more than one exists' do
      solutions << RDF::Query::Solution.new(edition: edition_val)
      solutions << RDF::Query::Solution.new(edition: 'foo')
      expect(isd.send(:imprint_display)).to eq edition_val
    end
    it 'uses first provisionActivityStatement if more than one exists' do
      solutions << RDF::Query::Solution.new(pub_info: pub_info)
      solutions << RDF::Query::Solution.new(pub_info: 'foo')
      expect(isd.send(:imprint_display)).to eq pub_info
    end
  end

  context '#manu_info' do
    let(:manu_place) { 'manu_place' }
    let(:manu_agent) { 'manu_agent' }
    let(:manu_date) { '1990' }
    it 'manufacture info is a concatenation of place, agent and date' do
      solutions << RDF::Query::Solution.new(manu_place: manu_place, manu_agent: manu_agent, manu_date: manu_date)
      expect(isd.send(:manu_info)).to eq "#{manu_place} : #{manu_agent}, #{manu_date}"
    end
    it 'manufacture info can be missing manu_place' do
      solutions << RDF::Query::Solution.new(manu_agent: manu_agent, manu_date: manu_date)
      expect(isd.send(:manu_info)).to eq "#{manu_agent}, #{manu_date}"
    end
    it 'manufacture info can be missing manu_agent' do
      solutions << RDF::Query::Solution.new(manu_place: manu_place, manu_date: manu_date)
      expect(isd.send(:manu_info)).to eq "#{manu_place} : #{manu_date}"
    end
    it 'manufacture info can be missing manu_date' do
      solutions << RDF::Query::Solution.new(manu_place: manu_place, manu_agent: manu_agent)
      expect(isd.send(:manu_info)).to eq "#{manu_place} : #{manu_agent}"
    end
    it 'manufacture info can be only manu_place' do
      solutions << RDF::Query::Solution.new(manu_place: manu_place)
      expect(isd.send(:manu_info)).to eq manu_place
    end
    it 'manufacture info can be only manu_agent' do
      solutions << RDF::Query::Solution.new(manu_agent: manu_agent)
      expect(isd.send(:manu_info)).to eq manu_agent
    end
    it 'manufacture info can be only manu_date' do
      solutions << RDF::Query::Solution.new(manu_date: manu_date)
      expect(isd.send(:manu_info)).to eq manu_date
    end
    it 'uses first bf:Manufacture provisionActivity if more than one exists' do
      solutions << RDF::Query::Solution.new(manu_place: manu_place, manu_date: manu_date)
      solutions << RDF::Query::Solution.new(manu_agent: manu_agent)
      expect(isd.send(:manu_info)).to eq "#{manu_place} : #{manu_date}"
    end
  end
end
