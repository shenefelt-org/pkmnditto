require 'httparty'
require 'json'
module TypesHelper
  $type_endpoint = "https://pokeapi.co/api/v2/type/"
  $types = []
  
  def get_all_types
    types = HTTParty.get($type_endpoint)
    return nil if types.empty? || types['results'].empty?

    return types['results'].map { |type| build_type_node(type_name: type['name']) }

  end


  def build_type_node(type_name: nil)
    return nil if type_name.nil? 
    type = get_type_by_name(type_name) if type_name.nil?
    return nil if type.nil? 
    return {
      name: type['name'],
      url: type['url'],
      damage_relations: type['damage_relations']
    } 

  end

  def get_damage_relations(type_url: nil)
    damage_relations = HTTParty.get(type_url)
    return nil if damage_relations.empty? || damage_relations['damage_relations'].empty?
    relations = damage_relations['damage_relations']
    double_damage = relations["double_damage_from"].map { |type| {name: type['name']} }
    # repeate double damage method for half damage etc. check for empty before mapping     

    return double_damage unless double_damage.empty?
  end
end
