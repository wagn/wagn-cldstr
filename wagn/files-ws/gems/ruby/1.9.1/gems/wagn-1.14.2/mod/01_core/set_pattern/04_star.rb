def label name
  'All "*" cards'
end

def prototype_args anchor
  { :name=>'*dummy' }
end

def pattern_applies? card
  card.cardname.star?
end
