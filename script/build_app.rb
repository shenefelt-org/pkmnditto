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
    destroy_db()
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

  return ( Pokemon.count.zero? && Move.count.zero? && Type.count.zero? && DamageRelation.count.zero?) ? true : false
end

bar.advance(name: "Types".ljust(20))
type_count = Type.count
build_types_from_restapi() unless !type_count.zero?
type_count = Type.count
prompt.say(
  "#{(pastel.bold.bright_magenta.on_black(!type_count.zero?) ? 'Success Types Table Built!' : 'fail')}"
)

bar.advance(name: "Pokemon".ljust(20))
sleep(0.1)
build_pkmn_from_graphql() if Pokemon.count.zero?
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
