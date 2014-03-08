
view :title do |args|
   _final_title args.merge( :title=>'Recent Changes' )
end

view :card_list do |args|
  search_vars[:item] ||= :change

  cards_by_day = Hash.new { |h, day| h[day] = [] }
  search_vars[:results].each do |card|
    begin
      stamp = card.updated_at
      day = Date.new(stamp.year, stamp.month, stamp.day)
    rescue Exception=>e
      day = Date.today
      card.content = "(error getting date)"
    end
    cards_by_day[day] << card
  end

  paging = _optional_render :paging, args
  %{
    #{ paging }
    #{
      cards_by_day.keys.sort.reverse.map do |day|
        %{
          <h2>#{format_date(day, include_time = false) }</h2>
          <div class="search-result-list">
            #{
               cards_by_day[day].map do |card|
                 %{
                   <div class="search-result-item item-#{ search_vars[:item] }">
                    #{ process_inclusion(card, :view=>search_vars[:item]) }
                  </div>
                 }
               end * ' '
            }
          </div>
        }
      end * "\n"
    }
    #{ paging }
  }
end

