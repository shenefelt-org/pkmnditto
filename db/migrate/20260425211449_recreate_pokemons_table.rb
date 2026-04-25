class RecreatePokemonsTable < ActiveRecord::Migration[8.1]
  def change
    drop_table :pokemon, if_exists: true
    create_table :pokemons do |t|
      t.integer :poke_id
      t.string :name
      t.integer :base_exp
      t.string :pkmn_type
      t.string :abilities, array: true, default: []
      t.string :default_sprite
    end
  end
end
