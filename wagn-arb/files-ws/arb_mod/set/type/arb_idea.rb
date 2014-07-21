event :require_arb_contact, :after=>:approve, :on=>:create do
  unless c = subcards['+contacts'] and !c['content'].blank?
    errors.add :contact, 'contact information required'
  end
end
