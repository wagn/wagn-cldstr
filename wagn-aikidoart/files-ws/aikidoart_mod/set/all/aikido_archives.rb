

format :html do

  view :taglink do |args|
    card_link "#{card.name}+*tagged", card.name, true
  end
  
end