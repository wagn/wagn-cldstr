#fixme -this is called by both initialize and update_attributes.  really should be optimized for new!
def assign_attributes args={}, options={}
  if args
    args = args.stringify_keys
    if newtype = args.delete('type')
      args['type_id'] = Card.fetch_id newtype
    end
    @subcards = extract_subcard_args! args
    reset_patterns
  end
  super args, options
end

def extract_subcard_args! args={}
  extracted_subcards = args.delete('subcards') || {}
  args.keys.each do |key|
    if key =~ /^\+/
      val = args.delete key
      val = { 'content' => val } if String === val
      extracted_subcards[key] = val
    end
  end
  extracted_subcards
end


protected

event :set_content, :before=>:store, :on=>:save do
  self.db_content = content || '' #necessary?
  self.db_content = Card::Content.clean! self.db_content if clean_html?
  self.selected_action_id = nil
  clear_drafts
  reset_patterns_if_rule saving=true
end


#fixme - the following don't really belong here, but they have to come after the reference stuff.  we need to organize a bit!

event :update_ruled_cards, :after=>:store do
  if is_rule?
#      warn "updating ruled cards for #{name}"
    self.class.clear_rule_cache
    left.reset_set_patterns

    if right_id==Card::ReadID and (name_changed? or trash_changed?)
      self.class.clear_read_rule_cache
      Card.cache.reset # maybe be more surgical, just Auth.user related
      expire #probably shouldn't be necessary,
      # but was sometimes getting cached version when card should be in the trash.
      # could be related to other bugs?
      in_set = {}
      if !(self.trash)
        if class_id = (set=left and set_class=set.tag and set_class.id)
          rule_class_ids = set_patterns.map &:pattern_id
          #warn "rule_class_id #{class_id}, #{rule_class_ids.inspect}"

          #first update all cards in set that aren't governed by narrower rule
           Auth.as_bot do
             cur_index = rule_class_ids.index Card[read_rule_class].id
             if rule_class_index = rule_class_ids.index( class_id )
                # Why isn't this just 'trunk', do we need the fetch?
                Card.fetch(cardname.trunk_name).item_cards(:limit=>0).each do |item_card|
                  in_set[item_card.key] = true
                  next if cur_index < rule_class_index
                  if cur_index >= rule_class_index
                    item_card.update_read_rule
                  end
                end
             # elsif rule_class_index = rule_class_ids.index( 0 )
 #               in_set[trunk.key] = true
 #               #warn "self rule update: #{trunk.inspect}, #{rule_class_index}, #{cur_index}"
 #   trunk.update_read_rule if cur_index > rule_class_index
             else warn "No current rule index #{class_id}, #{rule_class_ids.inspect}"
             end
          end

        end
      end

      #then find all cards with me as read_rule_id that were not just updated and regenerate their read_rules
      if !new_record?
        Card.where( :read_rule_id=>self.id, :trash=>false ).reject do |w|
          in_set[ w.key ]
        end.each &:update_read_rule
      end
    end

  end
end

event :process_read_rule_update_queue, :after=>:store do
  Array.wrap(@read_rule_update_queue).each { |card| card.update_read_rule }
  @read_rule_update_queue = []
end

#  set_callback :store, :after, :process_read_rule_update_queue, :prepend=>true

event :expire_related, :after=>:store do
  self.expire

  if self.is_structure?
    self.structuree_names.each do |name|
      Card.expire name
    end
  end
  # FIXME really shouldn't be instantiating all the following bastards.  Just need the key.
  # fix in id_cache branch
  self.dependents.each       { |c| c.expire }
  self.referencers.each      { |c| c.expire }
  self.name_referencers.each { |c| c.expire }
  # FIXME: this will need review when we do the new defaults/templating system
end

