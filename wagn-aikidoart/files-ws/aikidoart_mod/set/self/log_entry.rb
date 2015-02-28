
format do
  view :date_links do |args|
    if icard = Card["#{Auth.current.name}+initials"] and initials = icard.item_names.first
      [:today, :tomorrow].map do |date_type|
        %(<p>#{ log_link initials, date_type }</p>)
      end.join
    else
      "(no initials, ergo no logs)"
    end
  
  end

  def log_link initials, datetype
    date = ::Date.send(datetype).to_s.gsub '-', ''
    opts = { :text=> datetype.capitalize }
    card = Card.fetch "#{date}+#{initials}", :new=>{}
    if card.new_card?
      opts[:path_opts] = { :action=>:create, :type=>'Log Entry'}
      opts[:path_opts][:tomorrow] = true if datetype == :tomorrow
    end
    card_link card.name, opts
  end
end
