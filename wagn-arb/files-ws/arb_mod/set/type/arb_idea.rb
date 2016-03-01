event :require_arb_contact, :validate, on: :create do
  c = subcards['+contacts']
  unless c && c.content.present?
    errors.add :contact, 'contact information required'
  end
end
