event :set_contact_permissions, :on=>:create, :after=>:store do
  Auth.as_bot do
    permitted = [ Card['Staff'], left ].map { |p| "[[#{p.name}]]" }.join("\n")
    Card.create! :name=>"#{left.name}+*self+*update", :content=>permitted

    cr = creator
    if creator != left && creator.codename != 'anonymous'
      permitted << "\n[[#{creator.name}]]"
    end
    Card.create! :name=>"#{left.name}+*self+*read", :content=>permitted
  end
end
