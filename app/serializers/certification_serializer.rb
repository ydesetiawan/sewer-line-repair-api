class CertificationSerializer
  include JSONAPI::Serializer

  set_type :certification
  set_id :id

  attributes :certification_name, :issuing_organization, :certificate_number,
             :issue_date, :expiry_date, :certificate_url, :created_at, :updated_at

  belongs_to :company

  link :self do |certification|
    "/api/v1/companies/#{certification.company_id}/certifications/#{certification.id}"
  end
end
