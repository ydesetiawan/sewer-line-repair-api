class Certification < ApplicationRecord
  # Associations
  belongs_to :company

  # Validations
  validates :certification_name, presence: true

  # Scopes
  scope :active, -> { where("expiry_date IS NULL OR expiry_date > ?", Date.today) }
  scope :expired, -> { where("expiry_date < ?", Date.today) }
  scope :expiring_soon, -> { where(expiry_date: Date.today..30.days.from_now) }

  # Methods
  def expired?
    expiry_date.present? && expiry_date < Date.today
  end

  def expires_soon?
    expiry_date.present? && expiry_date.between?(Date.today, 30.days.from_now)
  end
end
