require 'rails_helper'

RSpec.describe 'Factory Tests' do
  describe 'factories' do
    it 'creates a valid country' do
      country = create(:country)
      expect(country).to be_valid
    end

    it 'creates a valid state' do
      state = create(:state)
      expect(state).to be_valid
      expect(state.country).to be_present
    end

    it 'creates a valid city' do
      city = create(:city)
      expect(city).to be_valid
      expect(city.state).to be_present
    end

    it 'creates a valid service_category' do
      category = create(:service_category)
      expect(category).to be_valid
    end

    it 'creates a valid company' do
      company = create(:company)
      expect(company).to be_valid
      expect(company.city).to be_present
    end

    it 'creates a valid review' do
      review = create(:review)
      expect(review).to be_valid
      expect(review.company).to be_present
    end

    it 'creates a valid certification' do
      certification = create(:certification)
      expect(certification).to be_valid
      expect(certification.company).to be_present
    end

    it 'creates a valid gallery_image' do
      gallery_image = create(:gallery_image)
      expect(gallery_image).to be_valid
      expect(gallery_image.company).to be_present
    end
  end
end
