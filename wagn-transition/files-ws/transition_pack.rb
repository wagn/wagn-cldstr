# -*- encoding : utf-8 -*-
module Wagn
  module Set::TransitionPack
    include Sets
    format :html
    
    define_view :core, :right=>:pattern_confidence do |args|
      star_card = Card[ "#{Card[:pattern_confidence].name}+#{Card[:image].name}" ]
      star = if star_card
        args[:size] ||= :icon
        subrenderer(star_card).render_core args
      else
        '*'
      end
      result = ''
      if item=card.item_names[0] and char = item[0,1] and num = char.to_i
        
        num.times { result += star }
        result   
      else
        '<!-- pattern_confidence error: invalid item -->'
      end
    end
    
    define_view :core, :right=>:pattern_summary do |args|
      add_name_context
      _final_core args
    end    
  end
end
