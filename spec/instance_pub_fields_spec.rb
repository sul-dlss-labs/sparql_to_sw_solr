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

  context '#add_publication_fields' do
    it 'includes pub year fields' do
      expect(isd).to receive(:add_pub_year_fields)
      isd.solr_doc_hash
    end
  end

  context '#add_pub_year_fields' do
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

end
