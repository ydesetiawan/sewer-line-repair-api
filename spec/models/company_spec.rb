require 'rails_helper'

RSpec.describe Company do
  describe 'geocoding' do
    let(:country) { create(:country, name: 'United States', code: 'US', slug: 'united-states') }
    let(:state) { create(:state, name: 'California', code: 'CA', slug: 'california', country: country) }
    let(:city) { create(:city, name: 'San Francisco', slug: 'san-francisco', state: state, latitude: 37.7749, longitude: -122.4194) }

    describe '.near' do
      let!(:company1) do
        create(:company,
               name: 'Downtown Plumbing',
               slug: 'downtown-plumbing',
               city: city,
               street_address: '100 Market St',
               zip_code: '94105',
               latitude: 37.7749,
               longitude: -122.4194)
      end

      let(:company2) do
        create(:company,
               name: 'Bay Area Repairs',
               slug: 'bay-area-repairs',
               city: city,
               street_address: '500 Howard St',
               zip_code: '94105',
               latitude: 37.7858,
               longitude: -122.3965)
      end

      let(:company3) do
        create(:company,
               name: 'Golden Gate Services',
               slug: 'golden-gate-services',
               city: city,
               street_address: '1000 Van Ness Ave',
               zip_code: '94109',
               latitude: 37.7877,
               longitude: -122.4205)
      end

      let(:company4) do
        create(:company,
               name: 'South Bay Plumbing',
               slug: 'south-bay-plumbing',
               city: city,
               street_address: '2000 Mission St',
               zip_code: '94110',
               latitude: 37.7625,
               longitude: -122.4189)
      end

      it 'finds companies within specified radius (miles)' do
        # Search from downtown San Francisco
        nearby_companies = described_class.near([37.7749, -122.4194], 1)

        expect(nearby_companies).to include(company1)
        expect(nearby_companies.count).to be >= 1
      end

      it 'returns companies ordered by distance' do
        # Search from company1 location
        nearby_companies = described_class.near([37.7749, -122.4194], 5)

        expect(nearby_companies.first).to eq(company1) # Should be closest to itself
      end

      it 'returns empty array when no companies within radius' do
        # Search from far away location (Los Angeles coordinates)
        nearby_companies = described_class.near([34.0522, -118.2437], 1)

        expect(nearby_companies).to be_empty
      end

      it 'supports different radius values' do
        # Small radius
        close_companies = described_class.near([37.7749, -122.4194], 1)

        # Large radius
        far_companies = described_class.near([37.7749, -122.4194], 50)

        expect(close_companies.count).to be <= far_companies.count
      end

      it 'can count nearby companies' do
        count = described_class.near([37.7749, -122.4194], 5).count

        expect(count).to be >= 1
        expect(count).to be_an(Integer)
      end
    end

    describe 'geocoding callbacks' do
      context 'when company has street address but no coordinates' do
        let(:company_without_coords) do
          build(:company,
                city: city,
                slug: 'test-company-1',
                street_address: '123 Main St',
                zip_code: '94102',
                latitude: nil,
                longitude: nil)
        end

        it 'geocodes address after validation' do
          # Stub Geocoder.search to return a mock result with coordinates
          mock_result = double(latitude: 37.7749, longitude: -122.4194, coordinates: [37.7749, -122.4194]) # rubocop:disable RSpec/VerifiedDoubles
          allow(Geocoder).to receive(:search).and_return([mock_result])

          company_without_coords.save

          expect(company_without_coords.latitude).to eq(37.7749)
          expect(company_without_coords.longitude).to eq(-122.4194)
        end
      end

      context 'when company already has coordinates' do
        let(:company_with_coords) do
          build(:company,
                city: city,
                slug: 'test-company-2',
                street_address: '123 Main St',
                latitude: 37.7749,
                longitude: -122.4194)
        end

        it 'does not geocode again' do
          # Should not call geocode since coordinates exist
          expect(company_with_coords).not_to receive(:geocode) # rubocop:disable RSpec/MessageSpies
          company_with_coords.save
        end
      end
    end
  end

  describe '#full_address' do
    let(:country) { create(:country, slug: 'us') }
    let(:state) { create(:state, name: 'California', slug: 'california', country: country) }
    let(:city) { create(:city, name: 'San Francisco', slug: 'san-francisco', state: state) }
    let(:company) do
      create(:company,
             city: city,
             slug: 'test-company-3',
             street_address: '123 Main St',
             zip_code: '94102')
    end

    it 'returns complete address string' do
      expect(company.full_address).to eq('123 Main St, San Francisco, California, 94102')
    end

    it 'handles missing street address' do
      company.street_address = nil
      expect(company.full_address).to eq('San Francisco, California, 94102')
    end

    it 'handles missing zip code' do
      company.zip_code = nil
      expect(company.full_address).to eq('123 Main St, San Francisco, California')
    end
  end

  describe 'validations' do
    it 'requires a name' do
      company = build(:company, name: nil)
      expect(company).not_to be_valid
      expect(company.errors[:name]).to include("can't be blank")
    end

    it 'generates slug from name before validation' do
      company = build(:company, name: 'Test Company', slug: nil)
      company.valid?
      expect(company.slug).to eq('test-company')
    end

    it 'validates slug uniqueness within city' do
      city = create(:city)
      create(:company, slug: 'test-company', city: city)
      duplicate = build(:company, slug: 'test-company', city: city)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:slug]).to include('has already been taken')
    end
  end
end
