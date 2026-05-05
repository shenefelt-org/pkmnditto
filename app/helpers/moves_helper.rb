require 'httparty'
require 'pastel'
require 'tty-prompt'
require 'tty-progressbar'

module MovesHelper
  # --- SETUP AND COMPATIBILITY ---
  unless defined?(Fixnum)
    Fixnum = Integer
  end

  unless defined?(Bignum)
    Bignum = Integer
  end

  def begin_process
    # Re-initializing these inside the method ensures they are available 
    # to the logic below regardless of how the module is included.
    pastel = Pastel.new
    prompt = TTY::Prompt.new

    if !Pokemon.count.zero? || !Move.count.zero? || !Type.count.zero? || !DamageRelation.count.zero?
      
      warning_msg = pastel.italic.bright_red.inverse.on_white(' WARNING: DB HAS DATA. Destroy and repopulate? (y/n) ')
      
      if prompt.yes?(warning_msg)
        destroy_db
      else
        prompt.say(pastel.italic.bright_red.inverse.on_white(' Skipping Deletion '))
      end
    end

    build_moves_from_restapi()
  end

  def destroy_db
    pastel = Pastel.new
    prompt = TTY::Prompt.new
    models = [Pokemon, Type, Move, DamageRelation]
    
    bar = TTY::ProgressBar.new(
      "Cleaning DB: [:bar] :item_name :percent", 
      total: models.length, 
      width: 30,
      complete: pastel.bright_red("="),
      incomplete: pastel.bright_green("-")
    )

    models.each do |model|
      bar.advance(item_name: model.name.ljust(20))
      model.destroy_all rescue nil
      sleep(0.1) 
    end

    bar.finish
    prompt.ok(pastel.bright_red('Database destruction complete.'))
  end

  def build_moves_from_restapi
    pastel = Pastel.new
    prompt = TTY::Prompt.new

    # 1. Get the initial list of moves
    url = "https://pokeapi.co/api/v2/move?limit=2000"
    response = HTTParty.get(url)

    unless response.success?
      prompt.error("Could not fetch move list from REST API. Status: #{response.code}")
      return false
    end

    moves_list = response.parsed_response["results"]
    prompt.say(pastel.cyan("\tFound #{moves_list.length} moves. Starting detailed import..."))

    bar = TTY::ProgressBar.new(
      "Building moves: [:bar] :name :percent",
      total: moves_list.length,
      width: 30
    )

    moves_list.each do |move|
      # Format the name for the UI
      display_name = move["name"].split("-").map(&:capitalize).join(" ")
      
      bar.advance(name: display_name.ljust(20))

      # 2. Fetch details for THIS specific move
      detail_response = HTTParty.get(move["url"])

      # If a specific move fails (like a 504), skip it instead of crashing
      unless detail_response.success? && detail_response.parsed_response.is_a?(Hash)
        prompt.warn(" Skipping #{display_name}: Server timed out on details.")
        next 
      end

      details = detail_response.parsed_response
      
      # 3. Extract English short effect
      effect_entries = details['effect_entries'] || []
      short_txt_node = effect_entries.find { |e| e.dig('language', 'name') == 'en' }
      short_txt = short_txt_node ? short_txt_node['short_effect'] : 'No description available'

      # 4. Create the Record
      Move.create(
        name: display_name,
        move_type: details.dig('type', 'name') || 'unknown',
        power: details['power'] || 0,
        short_text: short_txt
      )

      sleep(0.05) 
    end

    bar.finish
    prompt.ok(pastel.magenta("\nRestoration Complete! Moves built: #{Move.count}"))
    true
  end

end