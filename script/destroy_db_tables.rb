require 'tty'
require 'tty-prompt'
require 'tty-progressbar'
require "pastel"

pastel = Pastel.new
# Format string using your green label and multiple tokens
format = "#{pastel.green("Loading")} [:bar] :percent | Elapsed: :elapsed | ETA: :eta"

bar = TTY::ProgressBar.new(format, total: 50, complete: "■", incomplete: " ")

50.times do
  sleep(0.1)
  bar.advance
end


def destroy_current_db
  pkmn = destroy_pkmn()
  moves = destroy_moves()
  types = destroy_types()
  rel = destroy_damage_relations()
  puts "-> Success all tables dropped!" unless !pkmn || !moves || !types || !rel
  puts "-> Some failures occured, see above outputs."

end

def destroy_pkmn()
  pkmn_count = Pokemon.count
  return nil if pkmn_count.zero?
  bar = TTY::ProgressBar.new(format, total: pkmn_count, complete: "■", incomplete: " ")
  prompt = TTY::Prompt.new
  res = prompt.ask("Do you want to destroy #{pkmn_count} models?", %w(Yes No), default: "No")
  res = gets.chomp.downcase

  Pokemon.all.each do |pkmn| 
    puts "Destroying #{pkmn.name}"
    pkmn.destroy
    sleep(0.1)
    bar.advance
  end

  if res == 'yes'
    destroyed = Pokemon.destroy_all
    puts "-> Success destroyed #{destroyed.length} pokemon models" unless destroyed.length.zero?
    puts "-> Failed destroyed 0 pokemon models" if destroyed.length.zero?
  else
    prompt.say("-> Destruction cancelled, exiting script.")
    return false
  end

  true
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
    puts "-> Failure table not destroyed"
    return false
  end

  true
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
    puts "-> Failure table not destroyed"
    return false
  end

  true
end

def destroy_damage_relations()
  damage_relation_count = DamageRelation.count
  puts "Do you want to destroy #{damage_relation_count} models? [y/n]"
  res = gets.chomp.downcase
  if res == 'y'
    destroyed = DamageRelation.destroy_all
    puts "-> Success destroyed #{destroyed.length} Damage Relation Models models" unless destroyed.length.zero?
    puts "-> Failed destroyed 0 type models" if destroyed.length.zero?
  else
    puts "-> Failure table not destroyed"
    return false
  end

  true
end