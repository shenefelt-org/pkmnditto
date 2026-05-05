# temp fix for tty table err
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


include PokemonsHelper
include TypesHelper
include MovesHelper


@pastel = Pastel.new 
@prompt = TTY::Prompt.new

def begin_process
 
  if !Pokemon.count.zero? || !Move.count.zero? || !Type.count.zero? || !DamageRelation.count.zero?
    
    message = @pastel.italic.bright_red.inverse.on_white('WARNING: DB already has data. Destroy and repopulate? (y/n)')
    
    if @prompt.yes?(message)
      destroy_db
    else
      @prompt.say(@pastel.italic.bright_red.inverse.on_white('Skipping Deletion'))
    end
  end

  build
end

def destroy_db
  models = [Pokemon, Type, Move, DamageRelation]
  
  bar = TTY::ProgressBar.new(
    "Cleaning DB: [:bar] :item_name :percent", 
    total: models.length, 
    width: 30,
    complete: @pastel.bright_red("="),
    incomplete: @pastel.bright_green("-")
  )

  models.each do |model|
    bar.advance(item_name: model.name.ljust(20))
    model.destroy_all
    sleep(0.1) 
  end

  bar.finish
  @prompt.ok(@pastel.bright_red('Database destruction complete..'))

  return true
end

def build
  classes = [Pokemon, Move, Type]
  format = "#{@pastel.italic.bright_green('Building: :name')} :percent | ETA :eta"
  
  bar = TTY::ProgressBar.new(format, total: classes.length + 1, width: 50)

  classes.each do |model|
    bar.advance(0, name: model.name.ljust(15))

    if model.count.zero?
      case model.name
      when "Pokemon" then build_pkmn_from_graphql
      when "Move"    then build_moves_from_restapi
      when "Type"    then build_types_from_restapi
      end
    else
      @prompt.say(@pastel.bold.bright_yellow.on_black("\tSkipping #{model.name} - data exists"))
    end
    bar.advance(1)
  end


  bar.advance(0, name: "Learned Moves")
  unless Move.count.zero? || Pokemon.count.zero?
    assign_learned_moves
  end
  bar.advance(1)

  status_msg = PokemonMove.count.zero? ? 'ERR: Move Relations Failed' : 'Success: Assigned Move Relations'
  @prompt.say(@pastel.bold.bright_magenta.on_black(status_msg))

  !Pokemon.count.zero? && !Move.count.zero? && !Type.count.zero?
end



@prompt.say(@pastel.bold.bright_blue.on_black('Starting Database Population Script...'))

begin_process

puts "\n" + "="*20 + " RESULTS " + "="*20
puts "Build Pkmn: #{!Pokemon.count.zero? ? 'SUCCESS' : 'FAILED'} (#{Pokemon.count} records)"
puts "Build Move: #{!Move.count.zero? ? 'SUCCESS' : 'FAILED'} (#{Move.count} records)"
puts "Build Type: #{!Type.count.zero? ? 'SUCCESS' : 'FAILED'} (#{Type.count} records)"
puts "="*49