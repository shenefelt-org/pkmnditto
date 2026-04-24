class Item < ApplicationRecord
  include ItemsHelper


  def copy(node: nil)
    return nil if node.nil?
    self.name = node[:name]
    self.url = node[:url]
    self.sprite = node[:sprite]
    self.generations = get_game_versions(item: node)
    self.short_effect = get_short_effect(item: node)
  end

end
