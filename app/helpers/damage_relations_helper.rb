require 'httparty'
require 'json'
# get damage relations for all types
module DamageRelationsHelper
  include TypesHelper

  def build_damage_relations_from_restapi
    types = Type.all
    return nil if types.blank? || types.nil?

    types.each do |type|
      chain = HTTParty.get("https://pokeapi.co/api/v2/damage-relations #{type.name}")
    end

  end

  def get damage_relations(name: nil)

  end
end
