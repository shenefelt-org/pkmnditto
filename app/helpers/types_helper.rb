require 'httparty'
require 'json'
module TypesHelper
  $type_endpoint = "https://pokeapi.co/api/v2/type/"
  $types = []
  
  def get_all_types
    types = HTTParty.get($type_endpoint)
    return nil if types.empty? || types['results'].empty?

    return types['results'].map { |type| build_type_node(type_url: type['name']) }

  end


  def build_type_node(type_url: nil)
    type = get_type_by_name(type_name) if type_url.nil?
    return nil if type.nil? 
    return {
      name: type['name'],
      url: type['url'],
      # store an array of hashes
      damage_relations: [ get_damage_relations(type_url: type['url']) ]
    } 

  end

  def get_damage_relations(type_url: nil)
    damage_relations = HTTParty.get(type_url)
    return nil if damage_relations.empty? || damage_relations['damage_relations'].empty?
    return {
      double_damage_from: get_double_damage_from_relations(relations: damage_relations['damage_relations']),
      double_damage_to: get_double_damage_to_relations(relations: damage_relations['damage_relations']),
      half_damage_from: get_half_damage_from_relations(relations: damage_relations['damage_relations']),
      half_damage_to: get_half_damage_to_relations(relations: damage_relations['damage_relations']),
    }
  end

  def get_double_damage_from_relations(relations: nil)
    return nil if relations.nil? || relations["double_damage_from"].empty?
    double_damage = relations["double_damage_from"].map { |type| {name: type['name']} }
    return double_damage unless double_damage.empty?
  end

  def get_double_damage_to_relations(relations: nil)
    return nil if relations.nil? || relations["double_damage_to"].empty?
    double_damage = relations["double_damage_to"].map { |type| {name: type['name']} }
    return double_damage unless double_damage.empty?
  end

  def get_half_damage_from_relations(relations: nil)
    return nil if relations.nil? || relations["half_damage_from"].empty?
    half_damage = relations["half_damage_from"].map { |type| {name: type['name']} }
    return half_damage unless half_damage.empty?
  end

  def get_half_damage_to_relations(relations: nil)
    return nil if relations.nil? || relations["half_damage_to"].empty?
    half_damage = relations["half_damage_to"].map { |type| {name: type['name']} }
    return half_damage unless half_damage.empty?
  end


end
