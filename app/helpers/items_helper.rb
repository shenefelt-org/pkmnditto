require 'httparty'
require 'json'
require 'dotenv-rails'
Dotenv.load
# DEFAULT item will always be master-ball if none is passed in
module ItemsHelper
  $def_item = "https://pokeapi.co/api/v2/item/master-ball"
  $item_endpoint = "https://pokeapi.co/api/v2/item/"
  def get_all_items
    item_chain = HTTParty.get($item_endpoint)
    return if validate_response(item_chain).nil? 
    parsed_res = item_chain['results'].map do |item| 
      item_data = get_item_by_name(item[:name])
      { 
        name: item[:name], 
        url: item[:url],
        sprite: item_data['sprites']['default']
      }
    end
    return nil if parsed_res.blank? || parsed_res.empty?
    parsed_res
  end

  # Get any given item by name
  def get_item_by_name(item_name=$def_item)
    item = HTTParty.get("#{$item_endpoint}#{item_name}")
    return item.parsed_response unless item.blank?
  end

  # Get the items attributes 
  def get_item_attributes(item_name=$def_item)
    item_attributes = get_item_by_name(item_name)

    return nil if item_attributes.blank? || item_attributes['attributes'].empty?

    res = item_attributes['attributes']
    res.map 

    return res

  end

  # Get the flavor text entries for a given item. 
  def get_flavor_text_entries(item_name=$def_item)
    item = get_item_by_name(item_name)
    return nil if item.blank? || item['flavor_text_entries'].empty?


    return item['flavor_text_entries'].map do |entry|
      {
        text: entry["text"],
        language_name: entry["language"]["name"]
      }
    end
  end

end
