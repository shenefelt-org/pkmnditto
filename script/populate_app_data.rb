include PokemonsHelper
include TypesHelper
include MovesHelper

load Rails.root.join("script/destroy_db_tables.rb")

def destroy_current_db

  destroy_pkmn()
  destroy_moves()
  destroy_types()
end

pkmn_count = Pokemon.count
move_count = Move.count
type_count = Type.count

if(!pkmn_count.zero? || !move_count.zero? || !type_count.zero?)
  puts "WARNING: DB already has data in it. This script is meant to be run on an empty db. Do you want to destroy the current db and repopulate it? (y/n)"
  answer = gets.chomp.downcase
  if answer == 'y'
    destroy_current_db()
    puts "current db destroyed"
  else
    puts "exiting script"
    exit
  end
end

puts "populating pokemon.."
build_pkmn_from_graphql() unless !pkmn_count.zero?
pkmn_count = Pokemon.count
puts "-> #{(!pkmn_count.zero?) ? 'success' : 'fail'}"

puts "populating moves.."
build_moves_from_restapi() unless !move_count.zero?
move_count = Move.count
puts "-> #{(!move_count.zero?) ? 'success' : 'fail'}"

puts "populating types.."
build_types_from_restapi() unless !type_count.zero?
type_count = Type.count
puts "-> #{(!type_count.zero?) ? 'success' : 'fail'}"

puts "===== RESULTS ====="
puts "Build Pkmn #{(!pkmn_count.zero?) ? '-> success' : '-> failed'}\nbuilt #{pkmn_count} Pokemon models"
puts "Build Move #{(!move_count.zero?) ? '-> success' : '-> failed'}\nbuilt #{move_count} Move models"
puts "Build Type #{(!type_count.zero?) ? '-> success' : '-> failed'}\nbuilt #{type_count} Type models"
puts "===== END ====="
