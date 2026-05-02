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
  complete: "👻",
  incomplete: " ",
  clear: false,
}
bar = TTY::ProgressBar.new(format_string, bar_options)

def destroy_db()
  pastel = Pastel.new
  bar_options = {
    total: 4,
    width: 100,
    complete: "=",
    incomplete: "-",
    clear: false
  }
  format = "#{pastel.magenta('Destroying :name')} [:bar]"
  bar = TTY::ProgressBar.new(format, bar_options)
  methods = [Pokemon, Type, Move, DamageRelation]

  bar.itterate(methods).each do |model|
    bar.update(name: model.name.ljust(20))
    model.destroy_all
    sleep(0.1)
  end
  prompt.ok("Database Destroyed")
end


if(!Pokemon.count.zero? || !Move.count.zero? || !Type.count.zero? || !DamageRelation.count.zero?)
  if prompt.yes?(
    "#{pastel.italic.bright_red.inverse.on_white('WARNING: DB already has data in it. This script is meant to be run on an empty db. Do you want to destroy the current db and repopulate it? (y/n)')}",
    default: "n")
    destroy_db()
  else
    prompt.say(
      "#{pastel.italic.bright_red.inverse.on_white('Skipping Deletion')}"
    )
  end

end

prompt.say(
  "#{pastel.bold.bright_blue.on_black('Building Types Table..')}"
)
type_count = Type.count
bar.advance(name: "Types".ljust(20))
sleep(0.1)
build_types_from_restapi() unless !type_count.zero?
type_count = Type.count
prompt.say(
  "#{(pastel.bold.bright_magenta.on_black(!type_count.zero?) ? 'Success Types Table Built!' : 'fail')}"
)

# Build the Pokemon Table
prompt.say(
  "#{pastel.bold.bright_blue.on_black('Building Pokemon Table..')}"
)
build_pkmn_from_graphql() if Pokemon.count.zero?
sleep(0.1)
bar.advance(name: "Pokemon".ljust(20))
pkmn_count = Pokemon.count.zero?



move_count = Move.count
build_moves_from_restapi() unless !move_count.zero?
move_count = Move.count
prompt.say(
  "#{pastel.bold.bright_magenta.on_black((move_count.zero?) ? 'ERR' : 'Success Moves Table Built!')}"
)
bar.advance(name: "Moves".ljust(20))


prompt.say(
  "#{pastel.bold.bright_blue.on_black('Assigning Leanred Moves..')}"
)
bar.advance(name: "Learned Moves")
assign_learned_moves() unless Move.count.zero? || Pokemon.count.zero?
prompt.say(
  "#{pastel.bold.bright_magenta.on_black((PokemonMove.count.zero?) ? 'ERR' : 'Success Assigned Move Relations')}"
)







puts "===== RESULTS ====="
puts "Build Pkmn #{(!pkmn_count.zero?) ? '-> success' : '-> failed'}\nbuilt #{pkmn_count} Pokemon models"
puts "Build Move #{(!move_count.zero?) ? '-> success' : '-> failed'}\nbuilt #{move_count} Move models"
puts "Build Type #{(!type_count.zero?) ? '-> success' : '-> failed'}\nbuilt #{type_count} Type models"
puts "Build Damage Relations #{(!relations_count.zero?) ? '-> success' : '-> failed'}\nbuilt #{relations_count} Type models"
puts "===== END ====="

return true
