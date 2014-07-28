
event :create_missing_tags, :after=>:store, :on=>:save do
  item_names.each do |name|
    if !Card.exists? name
      Card.create :name=>name
    end
  end
end