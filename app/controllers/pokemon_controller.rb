class PokemonController < ApplicationController
    # GET /pokemon or /pokemon.json
  def index
    @pokemon = Pokemon.all
  end
end
