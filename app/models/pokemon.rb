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

  def self.from_api_payload(payload)
    return nil if payload.blank?

    pokemon = find_or_initialize_by(pokeapi_id: payload["id"])
    pokemon.assign_attributes(
      name: payload["name"],
      image_url: payload.dig("sprites", "front_default"),
      primary_type: payload.dig("types", 0, "type", "name"),
      height: payload["height"],
      weight: payload["weight"],
      base_experience: payload["base_experience"],
      raw_payload: payload
    )
    pokemon
  end

  private

  def normalize_name
    self.name = name.to_s.strip.downcase.presence
  end
end
