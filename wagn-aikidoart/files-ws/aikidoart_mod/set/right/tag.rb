

event :create_missing_tags, :finalize, on: :save do
  item_names.each do |tag|
    next if Card.exists? tag
    add_subcard tag
  end
end
