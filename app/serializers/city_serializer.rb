class CitySerializer
  include JSONAPI::Serializer

  set_type :city
  set_id :id

  attributes :name, :slug

  attribute :companies_count do |city|
    city.try(:companies_count) || city.companies.size
  end

  attribute :country do |city|
    {
      id: city.country.id,
      name: city.country.name,
      code: city.country.code,
      slug: city.country.slug
    }
  end

  attribute :state do |city|
    {
      id: city.state.id,
      name: city.state.name,
      code: city.state.code,
      slug: city.state.slug
    }
  end
end
