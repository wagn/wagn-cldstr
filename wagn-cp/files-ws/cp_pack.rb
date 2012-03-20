class Wagn::Renderer::Html
  
  define_view :titled do |args|
    wrap :titled, args do
      edit_link = if !card.virtual? && card.ok?(:update)
        text = (icon_card = Card['edit_icon']) ? subrenderer(icon_card)._render_core : 'edit' 
        link_to_action text, :edit, :class=>'slotter titled-edit-link'
      else
        ''
      end
#      follow_link = User.logged_in? ? _render_follow : ''
      
      name_styler + edit_link + 
      content_tag( :h1, fancy_title(card.name), :class=>'titled-header') + wrap_content(:titled, _render_core(args)) +
      _render_comment_box
    end
  end
 
  define_view :closed_branch do |args|
    has_subtopics = Card["#{card.cardname.trunk_name}+subtopics"]
    wrap :closed_branch do
      basic_branch :closed, !!has_subtopics
    end
  end
  
  define_view :open_branch do |args|
    @paging_params = { :limit=> 1000 }
    subtopics_card = Card.fetch "#{card.cardname.trunk_name}+subtopics+*refer to+unlimited"
    wrap :open_branch do
      basic_branch(:open) + subrenderer( subtopics_card, :item_view => :closed_branch )._render_content
    end
  end
  
  def basic_branch state, show_arrow=true
    conf = { :closed=>%w{ open open right}, :open=> %w{ closed close down } }
    
    arrow_link = if state==:open or show_arrow
      link_to '', path(:view, :view=>"#{conf[state][0]}_branch"), :title=>"#{conf[state][1]} #{card.name}",
          :class=>"title #{conf[state][2]}-arrow slotter", :remote=>true
    else
      %{ <a href="javascript:void()" class="title branch-placeholder"></a> }
    end
    
    %{ 
      <div class="closed-view">
        <div class="card-header">
          #{ arrow_link }
          #{ link_to_page card.cardname.trunk_name, nil, :class=>"branch-direct-link", :title=>"go to #{card.cardname.trunk_name}" }
        </div> 
        #{ wrap_content :closed, render_closed_content }
      </div>
    }
  end
  
  define_view :follow do |args|
    %{ <span class="cp-follow">#{ link_to }</span> }
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