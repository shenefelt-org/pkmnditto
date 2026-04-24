require 'httparty'
require 'json'
# DEFAULT item will always be master-ball if none is passed in
module ItemsHelper
  $def_item = "https://pokeapi.co/api/v2/item/master-ball"
  $item_endpoint = "https://pokeapi.co/api/v2/item/"
  $items = []
  
  def validate_response(response)
    return nil if response.blank? || response.empty? || response.success? != 200 || response.body.parsed_response.empty?
  end


  # get all items and include their sprites for display
  def get_all_items
    item_chain = HTTParty.get($item_endpoint)
    return nil if item_chain.blank? || item_chain.empty?
    parsed_res = item_chain['results'].map do |item| 
      item_data = get_item_by_name(item['name'])
      { 
        name: item['name'], 
        url: item['url'],
        sprite: item_data['sprites']['default'],
        flavor_text: get_flavor_text_entries($def_item, item_data),
        generations: get_game_versions($def_item, item_data),
        short_effect: get_short_effect($def_item, item_data)
      }
    end
    return nil if parsed_res.blank? || parsed_res.empty?
    $items = parsed_res
  end

  # build an item node off of the parsed http response
  def build_item_node(item_name: 'rare-candy', item: nil)
    item = get_item_by_name("rare-candy") if item.nil?
    return {
      name: item['name'],
      url: item['url'],
      sprite: item['sprites']['default'],
      flavor_text: get_flavor_text_entries($def_item, item),
      generations: get_game_versions($def_item, item),
      short_effect: get_short_effect($def_item, item)
    }
  end

  def print_all_items
    $items = get_all_items() if $items.blank? || $items.empty?
    $items.each_with_index do |item, index|
      exit if index >= 10 
      puts "Name: #{item[:name]}"
      puts "URL: #{item[:url]}"
      puts "Sprite: #{item[:sprite]}"
      puts "Flavor Text: #{item[:flavor_text]}"
      puts "Generations: #{item[:generations]}"
      puts "Short Effect: #{item[:short_effect]}"
      puts "-----------------------------"
    end
    "thats all queen" # Return nil to avoid printing the array of items again in the console
  end

  # Get any given item by name
  def get_item_by_name(item_name = $def_item)
    item = HTTParty.get("#{$item_endpoint}#{item_name}")
    return item.parsed_response unless item.blank?
  end

  # Get the flavor text entries for a given item. 
  def get_flavor_text_entries(item_name=$def_item, item = nil)
    if !item.nil?
      english = item['flavor_text_entries'].find { |entry| entry['language']['name'] == 'en' }
      return english['text'] unless english.nil? || english.empty?
    else
      item = get_item_by_name(item_name)
      english = item['flavor_text_entries'].find { |entry| entry['language']['name'] == 'en' }
      return english['text'] unless english.nil? || english.empty?
    end
  end

  # get the versions of the game the item is in
  def get_game_versions(item_name = $def_item, item = nil)
    item = get_item_by_name(item_name) if item.nil?
    return nil if item.blank? || item.empty?
    gen_names = []
    item['game_indices'].each do |key| 
      gen_name = HTTParty.get(key['generation']['url'])
      gen_names.push(gen_name['main_region']['name']) unless gen_name.blank? || gen_name.empty?
    end

    return gen_names unless gen_names.empty?
    return nil
  end

  # get the items short effect text
  def get_short_effect(item_name = $def_name, item = nil)
    item = get_item_by_name(item_name) if item.nil?
    return nil if item.blank? || item.empty? || item['effect_entries'].empty?
    effect_entry = item['effect_entries'].find {|entry| entry['language']['name'] == 'en'}
    return (effect_entry.empty?) ? nil : effect_entry['short_effect']
  end

  def search_for_item_name_input

    puts "What item are you looking for?"
    item = gets.chomp
    # parameterize converts any input with space to in-put and always downcases
    item_call = HTTParty("#{$item_endpoint}#{item.parameterize}")

  end


end
