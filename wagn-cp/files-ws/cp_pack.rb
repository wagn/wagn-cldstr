class Wagn::Renderer::Html
  
  # Special titled view.  Much of this is probably reusable
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  define_view :titled do |args|
    edit_link = type_link = follow_link = ''
    
    if !card.virtual? && card.ok?(:update)
      text = (icon_card = Card['edit_icon']) ? subrenderer(icon_card)._render_core : 'edit' 
      edit_link = link_to_action text, :edit, :class=>'slotter titled-edit-link'
    end

    if main?
      follow_link = render_watch 

      typecode = card.typecode
      if %w{ Foundations Topic Organization User Opportunity State County City }.member?(typecode)
        type_link = link_to_page Cardtype.name_for(typecode), nil, :class=>"cp-typelink cp-type-#{typecode}" 
      end
    end
    
    wrap :titled, args do
      add_name_context
      %{
        <div class="cp-titled-header">
          <div class="cp-titled-right">
            #{ follow_link }
            #{ edit_link } 
          </div>
          <div class="cp-title">
            #{ type_link }
            #{ content_tag :h1, fancy_title, :class=>'titled-header' }
          </div>
        </div>
        #{ wrap_content( :titled ) { _render_core args } }
        #{ render_comment_box }
      }
    end
  end
 
  # show default image if person has no image
  #~~~~~~~~~~~~~~~~~~~~~~
 
 
  define_view :missing, :ltype=>:user, :right=>:image do |args|
    wrap :missing_image do
      subrenderer( Card['missing person'] )._render_core
    end
  end
 
  # Customize watching/following.  
  # Too much work for what is really only changing text and hover behavior
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  define_view :watch do |args|
    wrap :watch do
      if card.watching_type?
        watching_type_cards
      else
        link_args = if card.watching?
          ["Following", :off, "stop sending emails about changes to #{card.cardname}", { :hover_content=>'Stop Following' }]
        else
          ["Follow", :on, "send emails about changes to #{card.cardname}"]
        end
        watch_link *link_args
      end
    end
  end

  
  define_view :watch, :type=>:cardtype do |args|
    wrap :watch do
      type_link = card.watching_type? ? "#{watching_type_cards} | " : ""
      plural = card.name.pluralize
      link_args = if card.watching?
        ["Following", :off, "stop sending", { :hover_content=>"Stop Following all #{plural}" } ]
      else
        ["Follow", :on, "send"]
      end
      link_args[0] += " all #{plural}"
      link_args[2] += " emails about changes to #{plural}"
      type_link + watch_link( *link_args )
    end
  end

  
  def watching_type_cards
    %{<span class="watch-no-toggle">Following all #{ card.type_name.pluralize }</span>}
  end
 
 
  # ALL the "branch" stuff is about the special Topics tree
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
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
      link_to '', path(:read, :view=>"#{conf[state][0]}_branch"), :title=>"#{conf[state][1]} #{card.name}",
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
        #{ wrap_content( :closed ) { render_closed_content } }
      </div>
    }
  end
  
  
  # Everything below is about the special navbox behavior
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  define_view :raw, :name=>:cp_navbox do |args|
    %{ <form action="#{Card.path_setting '/:search'}" id="navbox-form" method="get">
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
          #{ link_to_page fancy_title, card.name }
        </span>
        <span class="cp-item-date">
          #{ time_ago_in_words card.updated_at } ago
        </span>
        <span class="cp-item-type">
          #{ link_to_page card.type_name }
        </span>
      </div>
      <div class="cp-item-content">
        <div class="closed-content">#{ _render_closed_content }</div>
      </div>
      }
    end
  end

    
  alias_view(:raw, { :name=>:cp_navbox }, :core)
  
end


class Wagn::Renderer::Json < Wagn::Renderer
  # bit of a hack to make navbox results restrictable
  def goto_wql(term)
   xtra = search_params
   xtra.delete :default_limit
   xtra.merge( { :complete=>term, :limit=>8, :sort=>'name', :return=>'name' } )
  end
end

class Wagn::Renderer
  #probably need more general handling of WQL add-ons like this
  def params
    @params ||= begin
      p = super
      p.delete('_wql') if p['_wql'] && !p['_wql']['type'].present?
      p
    end      
  end
  
end