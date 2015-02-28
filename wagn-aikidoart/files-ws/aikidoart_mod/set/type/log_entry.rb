event :set_log_entry_name, :before=>:approve, :on=>:create do
  if name.blank?
    date = Card.create!(:type_code=>:log_date)
    if icard = Card["#{Auth.current.name}+initials"] and initials = icard.item_names.first
      self.name = "#{date.name}+#{initials}"
    else
      errors.add :name, "current user need initial to auto-generate log entry"
    end
  elsif !left and cardname.left =~ /^\d+$/
    Card.create! :name=>cardname.left, :type_code=>:log_date
  end
end
