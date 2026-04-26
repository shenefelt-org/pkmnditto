require 'httparty'
require 'json'
module TypesHelper
  $type_endpoint = "https://pokeapi.co/api/v2/type/"
  $default_type = "#{$type_endpoint}7"
  $types = []
  
  # also have this built a map that maps the name to the id of hte type
  def build_types_from_restapi
    types = HTTParty.get($type_endpoint)
    return nil if types.empty? || types['results'].empty?

    return types['results'].each { |type| build_type_model(type_hash: type) }

  end


  def build_type_model(type_hash: nil)
    return nil if type_hash.nil? || type_hash.blank?
    return Type.create(
      name: type_hash['name'],
      url: type_hash['url'],
    ) 

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
