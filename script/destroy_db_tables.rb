
def destroy_pkmn()
  pkmn_count = Pokemon.count
  puts "Do you want to destroy #{pkmn_count} models? [y/n]"
  res = gets.chomp.downcase
  if res == 'y'
    destroyed = Pokemon.destroy_all
    puts "-> Success destroyed #{destroyed.length} pokemon models" unless destroyed.length.zero?
    puts "-> Failed destroyed 0 pokemon models" if destroyed.length.zero?
  else
    puts "exiting script"
    exit
  end
end

def destroy_moves()
  move_count = Move.count
  puts "Do you want to destroy #{move_count} models? [y/n]"
  res = gets.chomp.downcase
  if res == 'y'
    destroyed = Move.destroy_all
    puts "-> Success destroyed #{destroyed.length} move models" unless destroyed.length.zero?
    puts "-> Failed destroyed 0 move models" if destroyed.length.zero?
  else
    puts "exiting script"
    exit
  end
end

def destroy_types()
  type_count = Type.count
  puts "Do you want to destroy #{type_count} models? [y/n]"
  res = gets.chomp.downcase
  if res == 'y'
    destroyed = Type.destroy_all
    puts "-> Success destroyed #{destroyed.length} type models" unless destroyed.length.zero?
    puts "-> Failed destroyed 0 type models" if destroyed.length.zero?
  else
    puts "exiting script"
    exit
  end
end