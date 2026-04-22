require "test_helper"
require "httparty"
require "json"

class PokemonHelperTest < ActionView::TestCase
    test "should get types" do
        types = get_types
        assert_not_nil types
        assert types.is_a?(Array)
        assert types.any? { |t| t.keys.first == "fire" }
    end
end
