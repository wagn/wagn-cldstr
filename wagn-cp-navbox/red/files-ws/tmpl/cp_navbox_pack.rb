class Wagn::Renderer::Html
  define_view(:raw, :name=>'cp navbox') do |args|
    %{ <form action="#{Card.path_setting '/*search'}" id="navbox-form" method="get">
      #{hidden_field_tag :view, 'content' }
      #{text_field_tag :_keyword, '', :class=>'navbox' }
      #{select_tag '_wql[type]', options_for_select([['All Content',nil], 'Foundations', 'Organizations', 'Topics', 'People'])}
      #{submit_tag 'search'}
     </form>}
  end
  alias_view(:raw, { :name=>'cp navbox' }, :core)
  
  def params
    @params ||= begin
      p = super
      p.delete('_wql') if p['_wql'] && !p['_wql']['type'].present?
      p
    end      
  end
end

#class Wagn::Renderer::Json < Wagn::Renderer
#  define_view(:complete, :name=>'*search') do |args|
#    term = params['term']
#    if term =~ /^\+/ && main = params['main']
#      term = main+term
#    end
#    
#    exact = Card.fetch_or_new(term)
#    goto_cards = Card.search( :complete=>term, :limit=>8, :sort=>'name', :return=>'name' )
#    goto_cards.unshift term if exact.virtual?
#    
#    JSON({ 
#      :search => true, # card.ok?( :read ),
#      :add    => (exact.new_card? && exact.cardname.valid? && !exact.virtual? && exact.ok?( :create )),
#      :new    => (exact.typecode=='Cardtype' && 
#                  Card.new(:typecode=>exact.codename).ok?(:create) && 
#                  [exact.name, exact.cardname.to_url_key]
#                 ),
#      :goto   => goto_cards.map { |name| [name, highlight(name, term), name.to_cardname.to_url_key] }
#    })    
#  end
#end