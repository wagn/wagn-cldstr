def delete
  update_attributes :trash => true unless new_card?
end

def delete!
  update_attributes! :trash => true unless new_card?
end


event :pull_from_trash, :before=>:store, :on=>:create do
  if trashed_card = Card.find_by_key_and_trash(key, true)
    # a. (Rails way) tried Card.where(:key=>'wagn_bot').select(:id), but it wouldn't work.  This #select
    #    generally breaks on cards. I think our initialization process screws with something
    # b. (Wagn way) we could get card directly from fetch if we add :include_trashed (eg).
    #    likely low ROI, but would be nice to have interface to retrieve cards from trash...
    self.id = trashed_card.id
    @from_trash = true
    @new_record = false
  end
  self.trash = false
  true
end

event :validate_delete, :before=>:approve, :on=>:delete do
  if !codename.blank?
    errors.add :delete, "#{name} is is a system card. (#{codename})"
  end
  
  undeletable_all_rules_tags = %w{ default style layout create read update delete }
  if junction? and left.codename == 'all' and undeletable_all_rules_tags.member? right.codename
    errors.add :delete, "#{name} is an indestructible rule"
  end
  
  # if account && Card::Revision.find_by_creator_id( self.id )  #ask ethan
  #   errors.add :delete, "Edits have been made with #{name}'s user account.\n  Deleting this card would mess up our revision records."
  # end
end

event :validate_delete_children, :after=>:approve, :on=>:delete do
  children.each do |child|
    child.supercard = self
    subcards[child.name]=child
    child.trash = true
    unless child.valid?
      child.errors.each do |field, message|
        errors.add field, "can't delete #{child.name}: #{message}"
      end
    end
  end
end
