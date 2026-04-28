class CreatePokemonMoves < ActiveRecord::Migration[8.1]
  def change
    create_table :pokemon_moves do |t|
      t.string :pokemon
      t.string :references
      t.string :move
      t.string :references

      t.timestamps
    end
  end
end
