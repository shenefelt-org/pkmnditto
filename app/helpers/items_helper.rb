require 'httparty'
require 'json'
module ItemsHelper

  def get_all_items
    item_chain = HTTParty.get('https://pokeapi.co/api/v2/items')
    return nil if item_chain.blank?
    parsed_chain = item_chain.parsed_results

    items = item_chain['results'].map {|name, url| {name = > url}}
  end

end
