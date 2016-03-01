event :set_contact_permissions, :finalize, on: :create do
  Auth.as_bot do
    permitted = [Card['Staff'], left].map { |p| "[[#{p.name}]]" }.join("\n")
    add_subcard "#{left.name}+*self+*update", content: permitted

    cr = creator
    if cr != left && cr.codename != 'anonymous'
      permitted << "\n[[#{creator.name}]]"
    end
    add_subcard "#{left.name}+*self+*read", content: permitted
  end
end
