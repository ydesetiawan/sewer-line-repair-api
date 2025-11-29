class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.string :company_id, limit: 255, null: false, index: true
      t.string :author_title
      t.string :author_image
      t.text :review_img_urls, array: true, default: []
      t.text :owner_answer
      t.datetime :owner_answer_timestamp_datetime_utc
      t.string :review_link
      t.integer :review_rating
      t.datetime :review_datetime_utc

      t.timestamps
    end

    add_index :reviews, [:company_id, :review_datetime_utc]
    add_index :reviews, :review_rating
    add_foreign_key :reviews, :companies, column: :company_id, primary_key: :id
    add_check_constraint :reviews, "review_rating >= 1 AND review_rating <= 5", name: "rating_range"
  end
end
