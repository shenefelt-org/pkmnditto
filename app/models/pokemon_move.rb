# app/models/pokemon_move.rb
class PokemonMove < ApplicationRecord
  belongs_to :pokemon
  belongs_to :move   
end