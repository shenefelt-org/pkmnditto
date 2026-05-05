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

    build_all
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

  def build_all
    pastel = Pastel.new
    prompt = TTY::Prompt.new
    
    # These methods are assumed to be in their respective helpers
    build_types_from_restapi
    build_moves_from_graphql
    build_pkmn_from_graphql

    # Handle Post-Build Relations
    unless Move.count.zero? || Pokemon.count.zero?
      assign_learned_moves
    end

    status_msg = PokemonMove.count.zero? ? 'ERR: Relations Failed' : 'Success: Assigned Move Relations'
    prompt.say(pastel.bold.bright_magenta.on_black(status_msg))
  end

  def build_moves_from_graphql
    pastel = Pastel.new
    prompt = TTY::Prompt.new

    query = <<~GQL
      query GetMoves {
        move {
          name
          power
          type {
            name
          }
          move_effect {
            move_effect_texts(where: {language_id: {_eq: 9}}) {
              short_effect
            }
          }
        }
      }
    GQL

    response = HTTParty.post(
      "https://graphql.pokeapi.co/v1beta2",
      headers: { 'Content-Type' => 'application/json' },
      body: { query: query }.to_json
    )

    if response.code != 200 || response["data"].nil?
      prompt.error("GraphQL Fetch Failed! Status: #{response.code}")
      return false
    end

    moves_data = response["data"]["move"]

    moves_data.each do |move_datum|
      formatted_name = move_datum["name"].split("-").map(&:capitalize).join(" ")
      effect_text = move_datum.dig("move_effect", "move_effect_texts")&.first&.[]("short_effect")
      
      Move.create(
        name: formatted_name,
        move_type: move_datum.dig("type", "name") || "unknown",
        power: move_datum["power"] || 0,
        short_text: effect_text || "No description available"
      )
    end
    true
  end
end