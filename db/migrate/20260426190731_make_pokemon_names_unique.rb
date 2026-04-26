class MakePokemonNamesUnique < ActiveRecord::Migration[8.1]
  def change
    drop_table :pokemons, if_exists: true
    create_table :pokemons do |t|
      t.integer :poke_id
      t.string :name, index: { unique: true }
      t.integer :base_exp
      t.string :pkmn_type
      t.text :abilities
      t.string :default_sprite
    end
  end
end
