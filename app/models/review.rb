class Review < ApplicationRecord
  # Associations
  belongs_to :company

  # Validations
  validates :reviewer_name, presence: true
  validates :review_date, presence: true
  validates :rating, presence: true, inclusion: { in: 1..5 }, numericality: { only_integer: true }

  after_destroy :update_company_rating
  # Callbacks
  after_save :update_company_rating

  # Scopes
  scope :verified, -> { where(verified: true) }
  scope :recent, -> { order(review_date: :desc) }

  private

  def update_company_rating
    company.update_rating!
  end
end
