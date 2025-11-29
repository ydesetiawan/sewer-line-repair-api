class Review < ApplicationRecord
  # Associations
  belongs_to :company

  # Validations
  validates :review_rating, presence: true, inclusion: { in: 1..5 }, numericality: { only_integer: true }
  validates :review_link, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true
  validates :author_image, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true

  # Store accessor for array fields
  attribute :review_img_urls, :string, array: true, default: -> { [] }

  # Callbacks
  after_save :update_company_rating
  after_destroy :update_company_rating

  # Scopes
  scope :recent, -> { order(review_datetime_utc: :desc) }
  scope :top_rated, -> { where('review_rating >= ?', 4).order(review_rating: :desc) }
  scope :with_owner_answer, -> { where.not(owner_answer: nil) }

  private

  def update_company_rating
    company.update_rating!
  end
end
