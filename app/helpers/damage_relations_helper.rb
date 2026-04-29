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
      process_status.push({ type: type.name, success: build_damage_relations_model(type_url: type.url, type_name: type.name) })
    end

    return process_status
  end

  # Parse out each relation type & then set them on the model 
  def build_damage_relations_model(type: nil)
    return nil if type.nil?
    type_chain = HTTParty.get(type_info)
    return nil if type_chain.blank?
    damage_relation = DamageRelation.create

    damage_relation

    damage_relation.half_damage_to = type_chain['damage_relations']['half_damage_to'].map do |type|
       type["name"]
    end

    damage_relation.half_damage_from = type_chain['damage_relations']['half_damage_from'].map do |type|
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

  # mod this to handle all 
def assoicate_damage_relations
  # 1. Create the Type
  normal = Type.find_or_create_by(name: "normal")
  moves = moves.all

  moves.each do |move|
    type = Type.find_by(name: move.move_type)
    damage_relation = DamageRelation.find_by(type: type)
    move.update(type: type)
    damage_relation.update(type: type)
  end

# 2. Assign the Move to that Type
  move = Move.find_by(name: "pound")
  move.update(type: normal)

# 3. Assign the Damage Relation to that Type
# (Assuming your damage relation record for Normal is ID 24)
  dr = DamageRelation.find(24)
  dr.update(type: normal)
end
end
