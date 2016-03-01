
event :validate_length, :validate do
  length = content.split.size
  if length > 300
    errors.add :content,
               "cannot be more than 300 characters (currently #{length})"
  end
end
