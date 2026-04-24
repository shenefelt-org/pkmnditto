class Item < ApplicationRecord
  include ItemsHelper

  serialize :generations, type: Array, default: [], coder: JSON

  def copy(node: nil)
    return nil if node.nil?
    self.assign_attributes(build_item_node(item_name: node[:name]))
    self.save
  end

end
