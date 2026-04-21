require "test_helper"

class PokemonTest < ActiveSupport::TestCase
  test "is valid with fixture data" do
    assert pokemon(:pikachu).valid?
  end

  test "normalizes name before validation" do
    record = Pokemon.new(pokeapi_id: 999, name: "  PiKaChu  ")

    assert record.valid?
    assert_equal "pikachu", record.name
  end

  test "requires unique pokeapi_id" do
    duplicate = Pokemon.new(pokeapi_id: pokemon(:pikachu).pokeapi_id, name: "pika-2")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:pokeapi_id], "has already been taken"
  end

  test "requires unique name case-insensitively" do
    duplicate = Pokemon.new(pokeapi_id: 1000, name: "PIKACHU")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "orders by pokedex number" do
    ordered = Pokemon.ordered_by_pokedex.to_a

    assert_equal [1, 25], ordered.map(&:pokeapi_id)
  end

  test "filters by type case-insensitively" do
    results = Pokemon.by_type("ELECTRIC")

    assert_equal [pokemon(:pikachu)], results
  end

  test "builds attributes from api payload" do
    payload = {
      "id" => 7,
      "name" => "squirtle",
      "sprites" => { "front_default" => "https://img/squirtle.png" },
      "types" => [{ "type" => { "name" => "water" } }],
      "height" => 5,
      "weight" => 90,
      "base_experience" => 63
    }

    pokemon = Pokemon.from_api_payload(payload)

    assert_equal 7, pokemon.pokeapi_id
    assert_equal "squirtle", pokemon.name
    assert_equal "water", pokemon.primary_type
    assert_equal "https://img/squirtle.png", pokemon.image_url
    assert_equal 5, pokemon.height
    assert_equal 90, pokemon.weight
    assert_equal 63, pokemon.base_experience
    assert_equal payload, pokemon.raw_payload
  end
end
