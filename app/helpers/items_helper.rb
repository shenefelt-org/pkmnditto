require 'httparty'
require 'json'
# DEFAULT item will always be master-ball if none is passed in
module ItemsHelper
  $def_item = "https://pokeapi.co/api/v2/item/master-ball"
  $item_endpoint = "https://pokeapi.co/api/v2/item/"
  $items = self.get_all_items()
  
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
        flavor_text: get_flavor_text_entries($def_item, item_data)
      }
    end
    return nil if parsed_res.blank? || parsed_res.empty?
    $items = parsed_res
  end

  def print_all_items
    $items = get_all_items() if $items.blank? || $items.empty?
    $items.each do |item|
      puts "Name: #{item[:name]}"
      puts "URL: #{item[:url]}"
      puts "Sprite: #{item[:sprite]}"
      puts "Flavor Text: #{item[:flavor_text]}"
      puts "-----------------------------"
    end
    nil # Return nil to avoid printing the array of items again in the console
  end

  # Get any given item by name
  def get_item_by_name(item_name=$def_item)
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


end
