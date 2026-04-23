require 'httparty'
require 'json'
require 'dotenv-rails'
Dotenv.load
# DEFAULT item will always be master-ball if none is passed in
module ItemsHelper
  $def_item = ENV['DEFAULT_ITEM']
  def get_all_items
    item_chain = HTTParty.get("https://pokeapi.co/api/v2/item/")
    return item_chain.parsed_response unless item_chain.blank?
  end

  # Get any given item by name
  def get_item_by_name(item_name=$def_item)
    item = HTTParty.get("#{ENV['ITEM_ENDPOINT']}#{item_name}")
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
