
format :html do
  view :taglink do |args|
    card_link "#{card.name}+*tagged", card.name, true
  end

  def menu_manage_link args
    menu_item_args = { related: Card[:manage].name }
    menu_item 'manage', 'tasks', menu_item_args, args[:html_args]
  end

  def menu_item_list args
    menu_item_list = super
    manage_card = Card[:manage]
    if card.real? && manage_card.ok?(:update)
      menu_item_list.insert 1, menu_manage_link(args)
    end
    menu_item_list
  end
end
