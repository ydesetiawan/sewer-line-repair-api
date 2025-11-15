class CitySerializer
  include JSONAPI::Serializer

  set_type :city
  set_id :id

  attributes :name, :slug

  attribute :companies_count do |state|
    state.try(:companies_count) || state.companies.size
  end

  attribute :country do |state|
    {
      id: state.country.id,
      name: state.country.name,
      code: state.country.code,
      slug: state.country.slug
    }
  end

  attribute :state do |city|
    {
      id: city.state.country.id,
      name: city.state.country.name,
      code: city.state.country.code,
      slug: city.state.country.slug
    }
  end
end
