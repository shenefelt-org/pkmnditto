require 'tty'
require 'tty-prompt'
require 'tty-progressbar'
require "pastel"



def dump_tables()
  prompt = TTY::Prompt.new
  pastel = Pastel.new
  format = "#{pastel.green("Destroying :name")} [:bar] :percent | Elapsed: :elapsed | ETA: :eta"
  bar_options = {
    count: 4,
    width: 100,
    complete: "=",
    incomplete: '-',
    clear: false
  }
  bar = TTY::ProgressBar.new(format, bar_options)

  if(prompt.yes?("Destroy all DB tables?", default: n))
    p = destroy_pkmn
    m = destroy_moves

end

def destroy_current_db
  prompt = TTy::Prompt.new
  pastel = Pastel.new
# Format string using your green label and multiple tokens
  format = "#{pastel.green("Destroying :name")} [:bar] :percent | Elapsed: :elapsed | ETA: :eta"
  bar_options = {
    count: 4,
    width: 100,
    complete: "=",
    incomplete: '-',
    clear: false
  }
  bar = TTY::ProgressBar.new(format, bar_options)
  prompt.yes("Clear all tables?" default: "n")
  bar.advance(1, name: "Pokemon")
  pkmn = destroy_pkmn()
  bar.advance(1, name: "Moves")
  moves = destroy_moves()
  bar.advance(1, name: "Types")
  types = destroy_types()
  prompt.ok("#{pastel.bold.bright_magenta('DB Destroyed!')}") unless !pkmn || !moves || !types || !rel
  bar.finish()


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