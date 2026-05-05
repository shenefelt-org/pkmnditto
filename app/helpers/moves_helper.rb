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
    
    build_types_from_restapi
    build_moves_from_graphql
    build_pkmn_from_graphql

    unless Move.count.zero? || Pokemon.count.zero?
      assign_learned_moves
    end

    status_msg = PokemonMove.count.zero? ? 'ERR: Relations Failed' : 'Success: Assigned Move Relations'
    prompt.say(pastel.bold.bright_magenta.on_black(status_msg))
  end

  def build_moves_from_graphql
  pastel = Pastel.new
  prompt = TTY::Prompt.new

  # 1. Define the Query
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

  prompt.say(pastel.cyan("Fetching moves via GraphQL..."))

  # 2. Execute the Request
  response = HTTParty.post(
    "https://graphql.pokeapi.co/v1beta2",
    headers: { 'Content-Type' => 'application/json' },
    body: { query: query }.to_json
  )

  # 3. Handle 504 Gateway Timeouts or Other Server Errors
  # The error you saw occurred because 'response' was a string "Gateway Timeout"
  unless response.success? && response.parsed_response.is_a?(Hash)
    prompt.error("API Error: #{response.code} - #{response.message}")
    prompt.error("The server might be down or timing out. Please try again in a few minutes.")
    return false
  end

  # 4. Safely Dig for Data
  # We call .parsed_response to ensure we are working with a Hash, not the Response object
  data = response.parsed_response
  moves_data = data.dig("data", "move")

  if moves_data.nil?
    prompt.error("No move data found in the response.")
    return false
  end

  # 5. Iterate and Create Records
  moves_data.each do |move_datum|
    # Format: "thunder-punch" -> "Thunder Punch"
    formatted_name = move_datum["name"].split("-").map(&:capitalize).join(" ")
    
    # Progress feedback (assuming @bar is available or just using prompt)
    if defined?(@bar)
      @bar.advance(1, name: formatted_name.ljust(20))
    else
      prompt.say(pastel.green("Creating: #{formatted_name}"))
    end

    # Safe navigation for nested effect text
    effect_array = move_datum.dig("move_effect", "move_effect_texts")
    short_txt = effect_array&.first ? effect_array.first["short_effect"] : "No description available"

    Move.create(
      name: formatted_name,
      move_type: move_datum.dig("type", "name") || "unknown",
      power: move_datum["power"] || 0,
      short_text: short_txt
    )
  end

  prompt.ok(pastel.magenta("\nSuccess! Moves Table has been built with #{Move.count} records."))
  true
end

end