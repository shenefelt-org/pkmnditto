include ItemsHelper

started = Time.now
puts "[#{started}] Fetching item index from PokeAPI..."

list = HTTParty.get("#{$item_endpoint}?limit=5000")
names = list["results"].map { |r| r["name"] }
puts "[#{Time.now}] Got #{names.size} items. Beginning population..."

ok = 0
fail = 0
names.each_with_index do |name, i|
  begin
    node = build_item_node(item_name: name)
    item = Item.find_or_initialize_by(name: name)
    if item.copy(node: node)
      ok += 1
    else
      fail += 1
      puts "  ! save failed for #{name}: #{item.errors.full_messages.join(', ')}"
    end
  rescue => e
    fail += 1
    puts "  ! exception for #{name}: #{e.class}: #{e.message}"
  end

  if (i + 1) % 50 == 0 || i == names.size - 1
    elapsed = (Time.now - started).to_i
    puts "[#{Time.now}] progress: #{i + 1}/#{names.size}  ok=#{ok}  fail=#{fail}  elapsed=#{elapsed}s  db_count=#{Item.count}"
  end
end

puts "[#{Time.now}] DONE. ok=#{ok}  fail=#{fail}  total_in_db=#{Item.count}  elapsed=#{(Time.now - started).to_i}s"
