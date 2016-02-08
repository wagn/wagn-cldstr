# show default image if user has no image
#~~~~~~~~~~~~~~~~~~~~~~


view :missing do |args|  # FIXME - implement using type_plus_right set when new functionality is in place
  if card.left and card.left.type_id == Card::UserID
    wrap args do
      subformat( Card['missing person'] )._render_core
    end
  else
    super args
  end
end