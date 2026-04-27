require 'httparty'
require 'json'
# get damage relations for all types
module DamageRelationsHelper
  include TypesHelper

  # check and make sure our db already has all types populated, if not buidl them
  def build_damage_relations_from_types
    types = (Type.count.zero?) ? build_types_from_restapi() : Type.all
    return nil if types.blank? || types.nil?
    process_status = []
    types.each do |type|
      process_status.push({ type: type.name, success: build_damage_relations_model(type_url: type.url) })
    end

    return process_status
  end

  # Parse out each relation type & then set them on the model 
  def build_damage_relations_model(type_url: nil)
    return nil if type_url.nil? 
    type_chain = HTTParty.get(type_url)
    return nil if type_chain.blank?
    damage_relation = DamageRelation.create

    damage_relation.half_damage_to = type_chain['damage_relations']['half_damage_to'].map do |r|
       r["name"]
    end

    damage_relation.half_damage_from = type_chain['damage_relations']['half_damage_from'].each do |type|
       type["name"]
    end

    damage_relation.double_damage_to = type_chain['damage_relations']['double_damage_to'].map do |type|
      type["name"]
    end
    
    damage_relation.double_damage_from = type_chain['damage_relations']['double_damage_from'].map do |type|
      type["name"]
    end

    damage_relation.no_damage_to = type_chain['damage_relations']['no_damage_to'].map do |type|
      type["name"]
    end
    damage_relation.no_damage_from = type_chain['damage_relations']['no_damage_from'].map do |type|
      type["name"]
    end


    return damage_relation.save.blank?
    
  end
end
