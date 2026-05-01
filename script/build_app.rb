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


if(!Pokemon.count.zero? || !Move.count.zero? || !Type.count.zero? || !DamageRelation.count.zero?)
  puts "WARNING: DB already has data in it. This script is meant to be run on an empty db. Do you want to destroy the current db and repopulate it? (y/n)"
  answer = gets.chomp.downcase
  if answer == 'y'
    destroy_current_db()
    puts "-> success "
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

puts "populating damage relations.."
build_damage_relations_from_types() unless !DamageRelation.count.zero?
relations_count = DamageRelation.count
puts "-> #{(!relations_count.zero?) ? 'success' : 'fail'}"

puts "===== RESULTS ====="
puts "Build Pkmn #{(!pkmn_count.zero?) ? '-> success' : '-> failed'}\nbuilt #{pkmn_count} Pokemon models"
puts "Build Move #{(!move_count.zero?) ? '-> success' : '-> failed'}\nbuilt #{move_count} Move models"
puts "Build Type #{(!type_count.zero?) ? '-> success' : '-> failed'}\nbuilt #{type_count} Type models"
puts "Build Damage Relations #{(!relations_count.zero?) ? '-> success' : '-> failed'}\nbuilt #{relations_count} Type models"
puts "===== END ====="

return true
