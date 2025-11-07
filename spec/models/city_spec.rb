require 'rails_helper'

RSpec.describe City do
  describe 'geocoding' do
    let!(:country) { create(:country, name: 'United States', code: 'US', slug: 'united-states') }
    let!(:state) { create(:state, name: 'California', code: 'CA', slug: 'california', country: country) }

    describe '.near' do
      let!(:city1) do
        create(:city,
               name: 'San Francisco',
               slug: 'san-francisco',
               state: state,
               latitude: 37.7749,
               longitude: -122.4194)
      end

      let!(:city2) do
        create(:city,
               name: 'Oakland',
               slug: 'oakland',
               state: state,
               latitude: 37.8044,
               longitude: -122.2712)
      end

      let!(:city3) do
        create(:city,
               name: 'San Jose',
               slug: 'san-jose',
               state: state,
               latitude: 37.3382,
               longitude: -121.8863)
      end

      let!(:city4) do
        create(:city,
               name: 'Los Angeles',
               slug: 'los-angeles',
               state: state,
               latitude: 34.0522,
               longitude: -118.2437)
      end

      it 'finds cities within specified radius' do
        # Search from San Francisco coordinates
        nearby_cities = described_class.near([37.7749, -122.4194], 20)

        expect(nearby_cities).to include(city1, city2)
        expect(nearby_cities).not_to include(city4) # LA is too far
      end

      it 'returns cities ordered by distance' do
        # Search from Oakland coordinates
        nearby_cities = described_class.near([37.8044, -122.2712], 50)

        expect(nearby_cities.count).to be >= 1
        expect(nearby_cities.first).to eq(city2) # Oakland should be closest
      end

      it 'returns empty array when no cities within radius' do
        # Search from middle of ocean
        nearby_cities = described_class.near([0.0, 0.0], 10)

        expect(nearby_cities).to be_empty
      end

      it 'supports different radius values' do
        # Small radius from San Francisco
        close_cities = described_class.near([37.7749, -122.4194], 10)

        # Large radius from San Francisco
        far_cities = described_class.near([37.7749, -122.4194], 400)

        expect(close_cities.count).to be >= 1
        expect(far_cities.count).to be >= close_cities.count
        expect(far_cities).to include(city4) # LA should be included with larger radius
      end
    end
  end

  describe 'validations' do
    it 'requires a name' do
      city = build(:city, name: nil)
      expect(city).not_to be_valid
      expect(city.errors[:name]).to include("can't be blank")
    end

    it 'generates slug from name before validation' do
      city = build(:city, name: 'Test City', slug: nil)
      city.valid?
      expect(city.slug).to eq('test-city')
    end

    it 'validates slug uniqueness within state' do
      state = create(:state)
      create(:city, slug: 'test-city', state: state)
      duplicate = build(:city, slug: 'test-city', state: state)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:slug]).to include('has already been taken')
    end
  end
end
