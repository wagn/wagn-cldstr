format do

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

format :csv do
  view :core do |args|
    _render_raw args
  end
end
