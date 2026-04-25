require 'httparty'
require 'json'
# DEFAULT item will always be master-ball if none is passed in
module ItemsHelper
  $def_item = "https://pokeapi.co/api/v2/item/master-ball"
  $item_endpoint = "https://pokeapi.co/api/v2/item/"
  $items = []
  $gen_names_map = []
  
  def validate_response(response)
    return nil if response.blank? || response.empty? || response.success? != 200 || response.body.parsed_response.empty?
  end


  # get all items and include their sprites for display
  def get_all_items
    item_chain = HTTParty.get($item_endpoint)
    return nil if item_chain.blank? || item_chain.empty?
    parsed_res = item_chain['results'].map do |item| 
      build_item_node(item_name: item['name'])
    end
    return nil if parsed_res.blank? || parsed_res.empty?
    $items = parsed_res
  end

  # build an item node off of the parsed http response
  # we have to get the url this way because we depend on mapping through all of the item objects first, the item itself doesn't have a url attribute in the res.
  # TODO FIX ARG CALL ON FLAVOR TEXT TO KEYWORDS
  def build_item_node(item_name: 'rare-candy')
    item = get_item_by_name(item_name)
    return {
      name: item['name'],
      url: "#{$item_endpoint}#{item['name']}",
      sprite: item['sprites']['default'],
      flavor_text: get_flavor_text_entries(item_name: $def_item, item: item),
      generations: {gen: get_game_versions(item_name: $def_item, item: item)}, # table has col that is bool for each gen i.e. honnen true kanto true etc.
      short_effect: get_short_effect(item_name: $def_item, item: item)
    }
  end

  def display_item_node(item_node: nil)
    return nil if item_node.nil? || item_node.empty?
    item_node.each_pair do |key, value|
      puts "#{key}: #{value}"
    end
    puts "-----------------------------"
    true
  end

  def print_all_items
    $items = get_all_items() if $items.blank? || $items.empty?
    $items.each { |item| display_item_node(item_node: item) }

    "thats all queen" # Return nil to avoid printing the array of items again in the console
  end

  # Get any given item by name
  def get_item_by_name(item_name = $def_item)
    item = HTTParty.get("#{$item_endpoint}#{item_name}")
    return item.parsed_response unless item.blank?
  end

  # Get the flavor text entries for a given item. 
  def get_flavor_text_entries(item_name: $def_item, item: nil)
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
  def get_game_versions(item_name: $def_item, item: nil)
    item = get_item_by_name(item_name) if item.empty?
    return nil if item.blank? || item.empty?
    gen_regions = []
    item['game_indices'].each do |key|
      gen_name = HTTParty.get(key['generation']['url'])
      next if gen_name.blank?
      gen_regions << { name: gen_name['main_region']['name'], url: gen_name['main_region']['url'] }
    end
    gen_regions.uniq.presence
  end

  # get the items short effect text
  def get_short_effect(item_name: $def_name, item: nil)
    item = get_item_by_name(item_name) if item.nil?
    return nil if item.blank? || item.empty? || item['effect_entries'].empty?
    effect_entry = item['effect_entries'].find {|entry| entry['language']['name'] == 'en'}
    return (effect_entry.empty?) ? nil : effect_entry['short_effect']
  end

  

  def search_for_item_name_input
    $items = get_all_items() if $items.blank? || $items.empty?
    puts "What item are you looking for?"
    item = gets.chomp
    # parameterize converts any input with space to in-put and always downcases
    item = $items.find { |item| item[:name] == item }

    return item unless item.nil? || item.empty?
    return false
    

  end


end
