class CreateCities < ActiveRecord::Migration[8.1]
  def change
    create_table :cities do |t|
      t.references :state, null: false, foreign_key: true, index: true
      t.string :name, null: false
      t.string :slug, null: false
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6

      t.timestamps
    end

    add_index :cities, [:state_id, :slug], unique: true
    add_index :cities, [:latitude, :longitude]
  end
end
