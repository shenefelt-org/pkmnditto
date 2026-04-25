class Item < ApplicationRecord
  include ItemsHelper

  serialize :generations, type: Hash, default: {}, coder: JSON

  def copy(node: nil)
    return nil if node.nil?
    # If the caller already passed us a fully-built node (from get_all_items
    # or build_item_node), use it directly to avoid a second API round-trip.
    # Otherwise fall back to fetching by name.
    full_node = node.key?(:sprite) ? node : build_item_node(item_name: node[:name])
    self.assign_attributes(full_node)
    self.save
  end

end
