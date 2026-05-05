unless defined?(Fixnum)
  Fixnum = Integer
end

unless defined?(Bignum)
  Bignum = Integer
end

require 'httparty'
require 'pastel'
require 'tty-prompt'
require 'tty-progressbar'

module MovesHelper
  def build_moves_from_restapi
    # 1. Fetch the initial list of moves
    response = HTTParty.get($move_endpoint)
    return false if response.nil? || response["results"].nil?
    
    moves_list = response["results"]
    pastel = Pastel.new
    prompt = TTY::Prompt.new

    # 2. Initialize the Progress Bar
    bar = TTY::ProgressBar.new(
      "Parsing :item_name [:bar] :percent", 
      total: moves_list.count, 
      width: 30
    )

    moves_list.each do |move| 
      bar.advance(item_name: move["name"].ljust(20))

      # 3. Fetch detailed move data
      move_datum = HTTParty.get(move["url"])
      next unless move_datum.success?

      # Find English short effect
      short_txt_node = move_datum['effect_entries'].find { |e| e['language']['name'] == 'en' }
      short_txt = short_txt_node ? short_txt_node['short_effect'] : 'ERR NO DATA'

      # 4. Create the Move Record
      model = Move.create(
        name: move["name"].split("-").join(" "),
        url: move["url"],
        move_type: move_datum.dig('type', 'name'),
        power: move_datum['power'] || 'data not available',
        short_text: short_txt
      )
      
      next if model.nil?

      # 5. Associate with Pokemon (learned_by_pokemon)
      if move_datum["learned_by_pokemon"]
        move_datum["learned_by_pokemon"].each do |ld|
          pokemon = Pokemon.find_by(name: ld["name"])
          next if pokemon.nil?

          PokemonMove.find_or_create_by(
            pokemon_id: pokemon.poke_id,
            move_id: model.id
          )
        end
      end

      # Small sleep so the user can actually see the progress bar movement
      sleep(0.05) 
    end

    # 6. Final status check
    final_count = Move.count
    if !final_count.zero?
      prompt.say("\nSuccess! Moves Table has been built!", color: :magenta)
      return true
    else
      prompt.say("\nFailure! Moves Table failed to build!", color: :cyan)
      return false
    end
  end
end