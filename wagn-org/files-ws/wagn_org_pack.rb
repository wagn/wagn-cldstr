class Wagn::Renderer::Html
  
  # Special titled view.  Much of this is probably reusable
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  define_view :shade do |args|
    wrap :shade, args do
      %{
        <h1>
          <a class="shade-link">#{ fancy_title card }</a>
        </h1>
        <div class="shade-content">#{ render_core }</div>
      }
    end
  end

=begin  
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
      %{
        #{ name_styler }
        <div class="cp-titled-header">
          <div class="cp-titled-right">
            #{ follow_link }
            #{ edit_link } 
          </div>
          <div class="cp-title">
            #{ type_link }
            #{ content_tag :h1, fancy_title(card.name), :class=>'titled-header' }
          </div>
        </div>
        #{ wrap_content :titled, _render_core(args) }
        #{ _render_comment_box }
      }
    end
  end
 
  # show default image if person has no image
  #~~~~~~~~~~~~~~~~~~~~~~
 
 
  define_view :missing, :ltype=>'person', :right=>'image' do |args|
    wrap :missing_image do
      subrenderer( Card['missing person'] )._render_core
    end
  end
=end
  # Customize watching/following.  
  # Too much work for what is really only changing text and hover behavior
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


end
