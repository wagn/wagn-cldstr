# -*- encoding : utf-8 -*-
class Card
  module Set  
    module TypePlusRight
      module Claim
        module WikirateTopic
          extend Set
          
          #explicitly override js topic tree
          view :editor, :ltype=>:claim, :right=>:wikirate_topic do |args|  
            _final_pointer_type_editor args
          end
          
          def options; options_restricted_by_source; end
        end
        
        module WikirateCompany
          extend Set
          def options; options_restricted_by_source; end
        end
        
        module WikirateMarket
          extend Set
          def options; options_restricted_by_source; end
        end          
      end
    end
  
  end




  class SetPattern::LtypeRtypePattern < SetPattern
    class << self
      def label name
        %{All "#{name.to_name.left_name}" + "#{name.to_name.tag}" cards}
      end
      def prototype_args anchor
        { }# :name=>"*dummy+#{anchor.tag}",
          #:loaded_left=> Card.new( :name=>'*dummy', :type=>anchor.trunk_name )
        #}
      end
      def anchor_name card
        left = card.loaded_left || card.left
        right = card.right
        ltype_name = (left && left.type_name) || Card[ Card.default_type_id ].name
        rtype_name = (right && right.type_name) || Card[ Card.default_type_id ].name
        "#{ltype_name}+#{rtype_name}"
      end
    end
    register 'ltype_rtype', :opt_keys=>[:ltype, :rtype], :junction_only=>true, :assigns_type=>true, :index=>4
    
  end
end


