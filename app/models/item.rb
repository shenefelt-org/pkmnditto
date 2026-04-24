class Item < ApplicationRecord
  include ItemsHelper


  def copy(node: nil)
    return nil if node.nil?
    self.name = node[:name]
    self.url = node[:url]
    self.sprite = node[:sprite]
    self.generations = node[:generations]
    self.short_effect = node[:short_effect]
  end

end
