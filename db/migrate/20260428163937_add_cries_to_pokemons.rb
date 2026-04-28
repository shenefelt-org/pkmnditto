class AddCriesToPokemons < ActiveRecord::Migration[8.1]
  def change
    add_column :pokemons, :cries, :string
  end
end
