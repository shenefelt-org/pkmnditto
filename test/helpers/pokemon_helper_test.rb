require "test_helper"
require "httparty"
require "json"
require "pokemon_helper"

class PokemonHelperTest < ActionView::TestCase
    test "should get types" do
        types = get_types
        assert_not_nil types
        assert types.is_a?(Array)
        assert types.any? { |t| t.keys.first == "fire" }
    end


    test "should get Mr.Mime" do
        mime = pokemon_helper.get_pokemon_by_name("mr-mime")
        assert mime.is_a?(Array)
        assert mime.first.name == "mr-mime"
    end
end
 