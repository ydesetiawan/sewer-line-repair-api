class CompanySerializer
  include JSONAPI::Serializer

  set_type :company
  set_id :id

  attributes :name, :slug, :phone, :email, :website, :street_address, :zip_code,
             :latitude, :longitude, :description, :average_rating, :total_reviews,
             :verified_professional, :licensed, :insured, :background_checked,
             :certified_partner, :service_guarantee, :service_level, :specialty,
             :working_hours, :about, :subtypes, :logo_url, :booking_appointment_link,
             :borough, :timezone, :created_at, :updated_at

  attribute :url_path, &:url_path

  attribute :full_address, &:full_address
end
