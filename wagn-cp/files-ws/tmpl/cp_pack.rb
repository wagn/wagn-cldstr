class Wagn::Renderer::Html
  
  define_view :titled do |args|
    wrap(:titled, args) do
      edit_link = if card.ok?(:update)
        text = (icon_card = Card['edit_icon']) ? subrenderer(icon_card)._render_core : 'edit' 
        link_to_action text, :edit, :class=>'slotter titled-edit-link'
      else
        ''
      end
      edit_link + content_tag( :h1, fancy_title(card.name), :class=>'titled-header') + wrap_content(:titled, _render_core(args))
    end
  end
  
  define_view :raw, :name=>'cp navbox' do |args|
    %{ <form action="#{Card.path_setting '/*search'}" id="navbox-form" method="get">
      #{hidden_field_tag :view, 'content' }
      #{hidden_field_tag :item, 'cp_result_item' }
      #{text_field_tag :_keyword, '', :class=>'navbox'
      }#{select_tag '_wql[type]', options_for_select([['All Content',nil], 'Foundations', 'Organizations', 'Topics', 'People'])
      }#{submit_tag 'search'}
     </form>}
  end
  
  define_view :cp_result_item do |args|
    wrap :cp_result_item, args do
      %{
      <hr>
      <div class="cp-result-top">
        <span class="cp-item-name">
          #{ link_to_page raw(fancy_title(self.showname || card)), card.name }
        </span>
        <span class="cp-item-date">
          #{ time_ago_in_words card.updated_at } ago
        </span>
        <span class="cp-item-type">
          #{ link_to_page card.typename }
        </span>
      </div>
      <div class="cp-item-content">
        <div class="closed-content">#{ _render_closed_content }</div>
      </div>
      }
    end
  end

    
  alias_view(:raw, { :name=>'cp navbox' }, :core)
  
end


class Wagn::Renderer::Json < Wagn::Renderer
  def goto_wql(term)
   xtra = search_params
   xtra.delete :default_limit
   xtra.merge( { :complete=>term, :limit=>8, :sort=>'name', :return=>'name' } )
  end
end

class Wagn::Renderer
  def params
    @params ||= begin
      p = super
      p.delete('_wql') if p['_wql'] && !p['_wql']['type'].present?
      p
    end      
  end
  
end