class Item < ApplicationRecord
  include ItemsHelper

  def initialize(node: item_node = nil)
    if !item_node.nil?
      self.name = item_node['name']
      self.url = item_node['url']
      self.sprite = item_node['sprites']['default']
      self.generations = get_game_versions(item: item_node)
      self.short_effect = get_short_effect(item: item_node)
    else
      self.name = $def_item
      self.url = "#{$item_endpoint}#{$def_item}"
      self.sprite = nil
      self.generations = nil
      self.short_effect = nil
    end
  end
end
