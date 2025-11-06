class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :company, null: false, foreign_key: true, index: true
      t.string :reviewer_name, null: false
      t.date :review_date, null: false
      t.integer :rating, null: false
      t.text :review_text
      t.boolean :verified, default: false

      t.timestamps
    end

    add_index :reviews, [:company_id, :review_date]
    add_index :reviews, :rating
    add_check_constraint :reviews, "rating >= 1 AND rating <= 5", name: "rating_range"
  end
end
