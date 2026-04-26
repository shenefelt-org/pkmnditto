class PokemonsController < ApplicationController
  before_action :set_pokemon, only: %i[ show edit update destroy ]

  # GET /pokemons
  def index
    @pokemons = Pokemon.ordered_by_pokedex
  end

  # GET /pokemons/1
  def show
  end

  # GET /pokemons/new
  def new
    @pokemon = Pokemon.new(nil)
  end

  # GET /pokemons/1/edit
  def edit
  end

  # POST /pokemons
  def create
    @pokemon = Pokemon.new(nil)
    @pokemon.assign_attributes(pokemon_params)

    if @pokemon.save
      redirect_to @pokemon, notice: "Pokemon was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /pokemons/1
  def update
    if @pokemon.update(pokemon_params)
      redirect_to @pokemon, notice: "Pokemon was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /pokemons/1
  def destroy
    @pokemon.destroy!
    redirect_to pokemons_path, notice: "Pokemon was successfully destroyed.", status: :see_other
  end

  private

  def set_pokemon
    @pokemon = Pokemon.find(params.expect(:id))
  end

  def pokemon_params
    params.expect(pokemon: [ :name, :pokeapi_id, :primary_type, :height, :weight, :base_experience, :image_url ])
  end
end
