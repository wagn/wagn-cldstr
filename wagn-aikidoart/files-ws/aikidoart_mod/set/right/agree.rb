
event :require_eula, :after=>:create do
  unless raw_content.to_i == 1
    msg = if msgcard = Card['eula error message']
      msgcard.content
    else
      "You must agree to the terms above to create an account."
    end
    errors.add :eula, msg
  end
end
