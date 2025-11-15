# frozen_string_literal: true

class StatesSerializer < ApplicationSerializer
  set_type :state
  set_id :id

  attributes :name, :code, :slug

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
end
