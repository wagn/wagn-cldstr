  # -*- encoding : utf-8 -*-


class Card
  def self.default_accounted_type_id
    Card::ArbContactID
  end
  
  module Set
    module Right
      module ArbEmail
        extend Card::Set
        view :missing do |args|
          if acct = card.trunk.account
            acct.email
          else
            _final_missing args
          end      
        end
        
        view :closed_missing do |args|
          if acct = card.trunk.account
            acct.email
          else
            _final_closed_missing args
          end      
        end
      end
    end
    
    module Type
      module ArbIdea
        extend Card::Set
        
        event :require_arb_contact, :after=>:approve, :on=>:create do
          unless c = cards['~plus~contacts'] and !c['content'].blank?
            errors.add :contact, 'contact information required'
          end
        end
      end
      
      
      module ArbProposal
        extend Card::Set
        event :require_proposal_fields, :after=>:approve, :on=>:create do
          %w{ title contacts proposal }.each do |field|
          
            unless c = cards["~plus~#{field}"] and !c['content'].blank?
              errors.add field, "#{field} required"
            end
          end
        end
      end
      
      module ArbContact
        extend Card::Set
        event :set_contact_permissions, :after=>:activate_account do
          Account.as_bot do
            permitted = [ Card['Staff'], self ].map { |p| "[[#{p.name}]]" }.join("\n")
            Card.create! :name=>"#{name}+*self+*update", :content=>permitted
          
            cr = creator
            if creator != self && creator.codename != 'anonymous'
              permitted << "\n[[#{creator.name}]]"
            end
            Card.create! :name=>"#{name}+*self+*read",   :content=>permitted
          end
        end
      end
    end
    
    
#    module All::Arb

#    end
  end

end
