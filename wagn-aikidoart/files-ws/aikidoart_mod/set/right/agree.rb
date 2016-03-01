
event :require_eula, :validate, on: :create do
  unless raw_content.to_i == 1
    msgcard = Card['eula error message']
    default_msg = 'You must agree to the terms above to create an account.'
    msg = msgcard ? msgcard.content : default_msg
    errors.add :eula, msg
  end
end
