# frozen_string_literal: true

class StatesSerializer < ApplicationSerializer

  set_type :state
  set_id :id

  attributes :name, :code, :slug

  attribute :country do |state|
    {
      id: state.country.id,
      name: state.country.name,
      code: state.country.code,
      slug: state.country.slug
    }
  end

end
