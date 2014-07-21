event :require_proposal_fields, :after=>:approve, :on=>:create do
  %w{ title contacts proposal }.each do |field|
  
    unless c = subcards["+#{field}"] and !c['content'].blank?
      errors.add field, "#{field} required"
    end
  end
end
