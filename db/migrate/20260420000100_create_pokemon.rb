class CreatePokemon < ActiveRecord::Migration[8.1]
  def change
    create_table :pokemon do |t|
      t.integer :pokeapi_id, null: false
      t.string :name, null: false
      t.string :image_url
      t.string :primary_type
      t.integer :height
      t.integer :weight
      t.integer :base_experience
      t.json :raw_payload

      t.timestamps
    end

    add_index :pokemon, :pokeapi_id, unique: true
    add_index :pokemon, :name, unique: true
    add_index :pokemon, :primary_type
  end
end
