class PokemonsController < ApplicationController
  before_action :set_pokemon, only: %i[ show edit update destroy ]

  # GET /pokemons
  def index
    @q = params[:q].to_s.strip
    @pokemons = Pokemon.all
    if @q.present?
      term = "%#{@q.downcase}%"
      @pokemons = @pokemons.where(
        "LOWER(name) LIKE :t OR LOWER(pkmn_type) LIKE :t OR LOWER(abilities) LIKE :t",
        t: term
      )
    end
    @pokemons = @pokemons.ordered_by_pokedex
  end

  # GET /pokemons/1
  def show
  end

  # GET /pokemons/new
  def new
    @pokemon = Pokemon.new
  end

  # GET /pokemons/1/edit
  def edit
  end

  # POST /pokemons
  def create
    @pokemon = Pokemon.new(pokemon_params)

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
    permitted = params.expect(pokemon: [ :poke_id, :name, :base_exp, :pkmn_type, :default_sprite, :abilities ])

    # `abilities` is serialized as a JSON Array on the model. The form sends a
    # newline- or comma-separated string, so normalize it here.
    if permitted[:abilities].is_a?(String)
      raw = permitted[:abilities].strip
      permitted[:abilities] =
        if raw.empty?
          []
        else
          begin
            parsed = JSON.parse(raw)
            parsed.is_a?(Array) ? parsed : [parsed.to_s]
          rescue JSON::ParserError
            raw.split(/[\n,]+/).map(&:strip).reject(&:empty?)
          end
        end
    end

    permitted
  end
end
