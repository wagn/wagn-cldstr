
event :validate_length, :after=>:approve do
  length = content.split.size
  errors.add :content, "cannot be more than 200 characters (currently #{length})" if length > 200
end
