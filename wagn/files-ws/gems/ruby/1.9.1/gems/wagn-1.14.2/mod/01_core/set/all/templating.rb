
def is_template?
  cardname.trait_name? :structure, :default
end

def is_structure?
  cardname.trait_name? :structure
end

def template
  # currently applicable templating card.
  # note that a *default template is never returned for an existing card.
  @template ||= begin
    @virtual = false
    if new_card?
      default_card = rule_card :default, :skip_modules=>true

      dup_card = dup
      dup_card.type_id = default_card ? default_card.type_id : Card.default_type_id


      if content_card = dup_card.structure_rule_card
        @virtual = true if junction?
        content_card
      else
        default_card
      end
    elsif tmpl = structure_rule_card
      # this is a mechanism for repairing bad data.  like #repair_key, it should be obviated and removed.
      if type_id != tmpl.type_id and tmpl.assigns_type?
        repair_type tmpl.type_id
      end
      tmpl
    end
  end
end

def structure
  if template && template.is_structure?
    template
  end
end

def virtual?
  return false unless new_card?
  if @virtual.nil?
    cardname.simple? ? @virtual=false : template
  end
  @virtual
end

def structure_rule_card
  card = rule_card :structure, :skip_modules=>true
  card && card.db_content.strip == '_self' ? nil : card
end

def structuree_names
  if wql = structuree_spec
    Auth.as_bot do
      Card::Query.new(wql.merge :return=>:name).run
    end
  else
    []
  end
end

# FIXME: content settings -- do we really need the reference expiration system?
#
# I kind of think so.  otherwise how do we handled patterned references in hard-templated cards?
# I'll leave the FIXME here until the need (and/or other solution) is well documented.  -efm

def expire_structuree_references
  update_structurees :references_expired => 1
end

def update_structurees args
  # note that this is not smart about overriding templating rules
  # for example, if someone were to change the type of a +*right+*structure rule that was overridden
  # by a +*type plus right+*structure rule, the override would not be respected.
  if query = structuree_spec
    Auth.as_bot do
      Card::Query.new( query.merge(:return => :id) ).run.each_slice(100) do |id_batch|
        Card.where( :id => id_batch ).update_all args
      end
    end
  end
end

def assigns_type?
  # needed because not all *structure templates govern the type of set members
  # for example, X+*type+*structure governs all cards of type X,
  # but the content rule does not (in fact cannot) have the type X.
  if is_structure?
    if set_pattern = Card.fetch( cardname.trunk_name.tag_name, :skip_modules=>true )
      pattern_code = set_pattern.codename and
      set_class    = Card::SetPattern.find( pattern_code ) and
      set_class.assigns_type
    end
  end
end

private

def repair_type template_type_id
  self.type_id = template_type_id
  update_column :type_id, type_id
  reset_patterns
end

def structuree_spec
  if is_structure? and c=trunk and c.type_id = Card::SetID  #could use is_rule?...
    c.get_spec
  end
end

event :update_structurees_type, :after=>:store, :changed=>:type_id do
  if assigns_type? # certain *structure templates
    update_structurees :type_id => type_id
  end
end
