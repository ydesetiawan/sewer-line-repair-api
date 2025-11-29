class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.string :company_id, limit: 255, null: false, index: true
      t.string :author_title
      t.string :author_image
      t.text :review_img_urls, array: true, default: []
      t.text :owner_answer
      t.timestamps :owner_answer_timestamp_datetime_utc
      t.string :review_link
      t.integer :review_rating
      t.timestamps :review_datetime_utc

      t.timestamps
    end

    add_index :reviews, [:company_id, :review_date]
    add_index :reviews, :rating
    add_foreign_key :reviews, :companies, column: :company_id, primary_key: :id
    add_check_constraint :reviews, "rating >= 1 AND rating <= 5", name: "rating_range"
  end
end
