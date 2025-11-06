class CreateStates < ActiveRecord::Migration[8.1]
  def change
    create_table :states do |t|
      t.references :country, null: false, foreign_key: true, index: true
      t.string :name, null: false
      t.string :code, limit: 10, null: false
      t.string :slug, null: false

      t.timestamps
    end

    add_index :states, [:country_id, :slug], unique: true
    add_index :states, [:country_id, :code]
  end
end
