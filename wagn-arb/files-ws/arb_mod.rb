 # -*- encoding : utf-8 -*-

# /card/update/contact?card[codename]=arb_contact

class Card
  def self.default_accounted_type_id
    Card::ArbContactID
  end
  
  module Set
    module Type::ArbContact
      extend Set
      event :set_contact_permissions, :on=>:create, :after=>:store do
        Account.as_bot do
          
        end
        
      end
    end
    
    
#    module All::Arb

#    end
  end

end
