class Wagn::Renderer::Html
  
  define_view :titled do |args|
    wrap(:titled, args) do
      edit_link = if card.ok?(:update)
        text = (icon_card = Card['edit_icon']) ? icon_card._render_source : 'edit' 
        link_to_action text, :edit, :class=>'slotter titled-edit-link'
      else
        ''
      end
      edit_link + content_tag( :h1, fancy_title(card.name), :class=>'titled-header') + wrap_content(:titled, _render_core(args))
    end
  end
  
  define_view(:raw, :name=>'cp navbox') do |args|
    %{ <form action="#{Card.path_setting '/*search'}" id="navbox-form" method="get">
      #{hidden_field_tag :view, 'content' }
      #{text_field_tag :_keyword, '', :class=>'navbox'
      }#{select_tag '_wql[type]', options_for_select([['All Content',nil], 'Foundations', 'Organizations', 'Topics', 'People'])
      }#{submit_tag 'search'}
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
