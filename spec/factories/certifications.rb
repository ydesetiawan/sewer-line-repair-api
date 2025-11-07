FactoryBot.define do
  factory :certification do
    company
    certification_name { 'Master Plumber License' }
    issuing_organization { 'State Licensing Board' }
    sequence(:certificate_number) { |n| "CERT-#{100_000 + n}" }
    issue_date { 2.years.ago.to_date }
    expiry_date { 1.year.from_now.to_date }
    certificate_url { 'https://example.com/cert.pdf' }

    trait :expired do
      expiry_date { 1.month.ago.to_date }
    end

    trait :no_expiry do
      expiry_date { nil }
    end

    trait :epa do
      certification_name { 'EPA Lead-Safe Certification' }
      issuing_organization { 'EPA' }
    end

    trait :osha do
      certification_name { 'OSHA Safety Training' }
      issuing_organization { 'OSHA' }
    end

    trait :trenchless do
      certification_name { 'Trenchless Technology Certification' }
      issuing_organization { 'NASSCO' }
    end
  end
end
