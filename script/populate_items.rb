include ItemsHelper

started = Time.now
puts "[#{started}] Fetching all items via GraphQL..."

nodes = get_all_items(limit: 5000)
abort "GraphQL fetch returned nothing" if nodes.blank?

puts "[#{Time.now}] Got #{nodes.size} items. Saving to DB..."

ok = 0
fail = 0
nodes.each_with_index do |node, i|
  begin
    item = Item.find_or_initialize_by(name: node[:name])
    if item.copy(node: node)
      ok += 1
    else
      fail += 1
      puts "  ! save failed for #{node[:name]}: #{item.errors.full_messages.join(', ')}"
    end
  rescue => e
    fail += 1
    puts "  ! exception for #{node[:name]}: #{e.class}: #{e.message}"
  end

  if (i + 1) % 200 == 0 || i == nodes.size - 1
    elapsed = (Time.now - started).to_i
    puts "[#{Time.now}] progress: #{i + 1}/#{nodes.size}  ok=#{ok}  fail=#{fail}  elapsed=#{elapsed}s  db_count=#{Item.count}"
  end
end

puts "[#{Time.now}] DONE. ok=#{ok}  fail=#{fail}  total_in_db=#{Item.count}  elapsed=#{(Time.now - started).to_i}s"
