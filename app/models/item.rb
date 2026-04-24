class Item < ApplicationRecord
  include ItemsHelper

  def copy(node: item_node = nil)
    return nil if node.nil?
    self.name = item_node[:name]
    self.url = item_node[:url]
    self.sprite = item_node[:sprite]
    self.generations = get_game_versions(item: item_node)
    self.short_effect = get_short_effect(item: item_node)
  end

end
