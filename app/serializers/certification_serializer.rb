# frozen_string_literal: true

class CertificationSerializer
  include JSONAPI::Serializer

  set_type :certification
  set_id :id

  attributes :certification_name, :issuing_organization, :issue_date, :expiry_date,
             :certificate_number, :certificate_url, :created_at

  # Relationships
  belongs_to :company, serializer: :company

  # Self link
  link :self do |object|
    "/api/v1/certifications/#{object.id}"
  end
end

