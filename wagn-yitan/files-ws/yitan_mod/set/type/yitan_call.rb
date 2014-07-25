
format :rss do
  view :feed_item do |args|
    super args
    if encl = Card["#{card.name}+podcast"]
      @xml.enclosure :url=>encl.content, :length=>0, :type=>'audio/mp4'
    end
  end
end