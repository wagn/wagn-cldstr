
event :validate_length, :after=>:approve do
  length = content.split.size
  errors.add :content, "cannot be more than 300 characters (currently #{length})" if length > 300
end
