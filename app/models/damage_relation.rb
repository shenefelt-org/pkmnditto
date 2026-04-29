class DamageRelation < ApplicationRecord
  serialize :half_damage_to, coder: JSON
  serialize :half_damage_from, coder: JSON
  serialize :double_damage_to, coder: JSON
  serialize :double_damage_from, coder: JSON
  serialize :no_damage_to, coder: JSON
  serialize :no_damage_from, coder: JSON
  belongs_to :type

  
  def compare_pkmn_types(pkmn_a: nil, pkmn_b: nil, by_name: false)
      return nil if pkmn_a.nil? || pkmn_b.nil?
      
      if(by_name)
        both_pkmn = nil;
        pkmn_a = Pokemon.find_by(name: pkmn_a)
        pkmn_b = Pokemon.find_by(name: pkmn_b)
        both_pkmn = pkmn_a.is_a?(Pokemon) && pkmn_b.is_a?(Pokemon)
        return nil if !both_pkmn
      end

      

  end
end