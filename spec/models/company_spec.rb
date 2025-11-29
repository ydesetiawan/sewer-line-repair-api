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
               postal_code: '94105',
               latitude: 37.7749,
               longitude: -122.4194)
      end

      let(:company2) do
        create(:company,
               name: 'Bay Area Repairs',
               slug: 'bay-area-repairs',
               city: city,
               street_address: '500 Howard St',
               postal_code: '94105',
               latitude: 37.7858,
               longitude: -122.3965)
      end

      let(:company3) do
        create(:company,
               name: 'Golden Gate Services',
               slug: 'golden-gate-services',
               city: city,
               street_address: '1000 Van Ness Ave',
               postal_code: '94109',
               latitude: 37.7877,
               longitude: -122.4205)
      end

      let(:company4) do
        create(:company,
               name: 'South Bay Plumbing',
               slug: 'south-bay-plumbing',
               city: city,
               street_address: '2000 Mission St',
               postal_code: '94110',
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
                postal_code: '94102',
                latitude: nil,
                longitude: nil)
        end
      end
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
