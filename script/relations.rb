temp = Type.first.name
temp2 = DamageRelation.find_by(pkmn_type: temp)
puts "Err no relations found for #{temp}" unless !temp2.blank?

puts "Relations for #{temp} are as follows: \n"
puts "Double Damage To: #{temp2.double_damage_to} \n"
puts "Double Damage From: #{temp2.double_damage_from}"
puts "Half Damage To: #{temp2.half_damage_to}"
puts "Half Damage From: #{temp2.half_damage_from}"
puts "No Damage To: #{temp2.no_damage_to}"
puts "No Damage From: #{temp2.no_damage_from}"

