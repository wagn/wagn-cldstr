# -*- encoding : utf-8 -*-
module Card::Set::Yitan

  extend Card::Set
  format :rss do
    view :feed_item, :type=>:yitan_call do |args|
      _final_feed_item args
      if encl = Card["#{card.name}+podcast"]
        @xml.enclosure :url=>encl.content, :length=>0, :type=>'audio/mp4'
      end
    end
  end
  
end