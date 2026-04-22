include PokemonsHelper
class Pokemon < ApplicationRecord
  before_validation :normalize_name

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :pokeapi_id, presence: true, uniqueness: true,
                        numericality: { only_integer: true, greater_than: 0 }
  validates :height, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :weight, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :base_experience, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  scope :ordered_by_pokedex, -> { order(:pokeapi_id) }
  scope :by_type, ->(type_name) { where("LOWER(primary_type) = ?", type_name.to_s.downcase) }

  def initialize(pokemon = $default_pokemon)
    super()
    return if pokemon.blank?

    self.name = pokemon["name"]
    self.pokeapi_id = pokemon["id"]
    self.height = pokemon["height"]
    self.weight = pokemon["weight"]
    self.base_experience = pokemon["base_experience"]

    types = pokemon["types"] || []
    primary_type_info = types.find { |t| t["slot"] == 1 }
    secondary_type_info = types.find { |t| t["slot"] == 2 }

    self.primary_type = primary_type_info ? primary_type_info.dig("type", "name") : nil
    self.secondary_type = secondary_type_info ? secondary_type_info.dig("type", "name") : nil
  end

  private

  def normalize_name
    self.name = name.to_s.strip.downcase.presence
  end
end
