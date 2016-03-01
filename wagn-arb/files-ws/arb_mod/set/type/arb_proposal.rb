event :require_proposal_fields, :validate, on: :create do
  %w( title contacts proposal ).each do |field|
    c = subcards["+#{field}"]
    errors.add field, "#{field} required" unless c && c.content.present?
  end
end
