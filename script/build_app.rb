# temp fix for tty table err
# Add this BEFORE any TTY requires
unless defined?(Fixnum)
  Fixnum = Integer
end

unless defined?(Bignum)
  Bignum = Integer
end

require 'tty'
require 'tty-prompt'
require 'tty-progressbar'
require "pastel"

# this will always run when trying to populate as to avoid importing data from the api that is already stored. if there is already data in the table users will need to confirm they want
# to dump the table.
include PokemonsHelper
include TypesHelper
include MovesHelper

load Rails.root.join("script/destroy_db_tables.rb")

pastel = Pastel.new 
prompt = TTY::Prompt.new
format_string = "#{pastel.bold.bright_magenta.inverse.on_black('Building :name')} {:bar} :percent"

bar_options = {
  total: 4,
  width: 100,
  complete: "=",
  incomplete: "-",
  clear: false,
}
bar = TTY::ProgressBar.new(format_string, bar_options)


if(!Pokemon.count.zero? || !Move.count.zero? || !Type.count.zero? || !DamageRelation.count.zero?)
  if prompt.yes?(
    "#{pastel.italic.bright_red.inverse.on_white('WARNING: DB already has data in it. This script is meant to be run on an empty db. Do you want to destroy the current db and repopulate it? (y/n)')}",
    default: "n")
    destroyed = destroy_db()

  else
    prompt.say(
      "#{pastel.italic.bright_red.inverse.on_white('Skipping Deletion')}"
    )
  end

end

def destroy_db()
  prompt = TTY::Prompt.new
  methods = [Pokemon.class, Type.class, Move.class, DamageRelation.class]
  bar = TTY::ProgressBar.new(
  "Cleaning DB: [:bar] :item_name :percent", 
  total: methods.length, 
  width: 30,
  complete: pastel.bright_red("="),
  incomplete: pastel.bright_green("-"),
  )

methods.each do |model_data|
    bar.advance(item_name: model_data.name.ljust(20))
    
    model_data.destroy_all
    
    sleep(0.3) 
  end
  bar.finish()
  prompt.ok("#{pastel.bright_red('Database destruction complete..')}")

  return true
end

def build()
  prompt = TTY::Prompt.net
  pastel = Pastel.new
  format = "#{pastel.italic.bright_green('Building: :name')} :percent | ETA :eta"

classes = [Pokemon, Move, Type] # Use the constants directly

classes.each do |model|
  bar.advance(1, name: model.name.ljust(20))

  if model.count.zero?
    case model.name
    when "Pokemon"
      build_pkmn_from_graphql()
    when "Move"
      build_moves_from_restapi()
    when "Type"
      build_types_from_restapi()
    end
  else
    prompt.say("#{pastel.bold.bright_yellow.on_black("Skipping #{model.name} - already has data")}")
  end
end
  bar.advance(name: "Learned Moves")
  assign_learned_moves() unless Move.count.zero? || Pokemon.count.zero?
  prompt.say(
    "#{pastel.bold.bright_magenta.on_black((PokemonMove.count.zero?) ? 'ERR' : 'Success Assigned Move Relations')}" 
  )
  return (!Pokemon.count.zero? && !Move.count.zero? && !Type.count.zero?) ? true : false
end

prompt.say(
  "#{pastel.bold.bright_blue.on_black('Assigning Leanred Moves..')}"
)








puts "===== RESULTS ====="
puts "Build Pkmn #{(!pkmn_count.zero?) ? '-> success' : '-> failed'}\nbuilt #{pkmn_count} Pokemon models"
puts "Build Move #{(!move_count.zero?) ? '-> success' : '-> failed'}\nbuilt #{move_count} Move models"
puts "Build Type #{(!type_count.zero?) ? '-> success' : '-> failed'}\nbuilt #{type_count} Type models"
puts "===== END ====="

return true
