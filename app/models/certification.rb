class Certification < ApplicationRecord
  # Associations
  belongs_to :company

  # Validations
  validates :certification_name, presence: true

  # Scopes
  scope :active, -> { where('expiry_date IS NULL OR expiry_date > ?', Time.zone.today) }
  scope :expired, -> { where('expiry_date < ?', Time.zone.today) }
  scope :expiring_soon, -> { where(expiry_date: Time.zone.today..30.days.from_now) }

  # Methods
  def expired?
    expiry_date.present? && expiry_date < Time.zone.today
  end

  def expires_soon?
    expiry_date.present? && expiry_date.between?(Time.zone.today, 30.days.from_now)
  end
end
