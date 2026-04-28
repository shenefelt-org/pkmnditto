class AddWeaknessToPokemonsTable < ActiveRecord::Migration[8.1]
  def change
    add_reference :pokemons_tables, :type, null: false, foreign_key: true
    add_reference :pokemons_tables, :pokemon, null: false, foreign_key: true
  end
end
