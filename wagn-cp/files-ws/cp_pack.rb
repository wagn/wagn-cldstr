class Card
  module Set::All::Connectipedia
    extend Set


    event :propose_mmt_restriction, :after=>:store, :on=>:create do
      role_name = 'MMT staff'
      if !nested_edit and
        !Account.always_ok? and                                                             # user is not admin
        Account.as_card.fetch(:trait=>:roles, :new=>{}).item_names.member?( role_name ) and # user is mmt staff
        who_can(:read) != [ Card[role_name].id ]                                       # card is not already restricted to MMT Staff

        case comment_author #KLUDGE!!! using this to hold restriction info.  need to figure out how to get params through.
        when nil
          self.errors.add :mmt, 'mmt confirm'
          self.error_view = :mmt_confirm
          raise ActiveRecord::Rollback, "kludge"
        when 'restrict'
          Account.as_bot do
            [:read, :update, :delete].each do |task|
              Card.create! :name=>"#{name}+*self+*#{task}", :content=>"[[#{role_name}]]"
            end
          end
        when 'allow'
          # noop
        end
      end
    end

    format :html do
  
      # Special titled view.  Much of this is probably reusable
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
      view :titled do |args|
        edit_link = type_link = ''
      
        if main?
          @@displayed_type_ids ||= %w{ Foundations Topic Organization Person Opportunity State County City }.map { |n| Card[n].id }
          if @@displayed_type_ids.member? card.type_id
            type_link = link_to_page card.type_name, nil, :class=>"cp-typelink cp-type-#{ Card::Codename[ card.type_id ] }" 
          end
        end
    
        wrap :titled, args do
          %{
            <div class="cp-titled-header">
              <div class="cp-titled-right">
                #{ render_watch if main? }
                #{ optional_render :menu, args, args[:menu_default_hidden] || false }
              </div>
              <div class="cp-title">
                #{ type_link }
                #{ _render_title args }
              </div>
            </div>
            #{ wrap_content(:titled, :body=>true) { _render_core args } }
            #{ render_comment_box }
          }
        end
      end
    
      view :menu_link, :perms=>:update, :denial=>:blank do |args|
        %{
          <a>
            #{
              if icon_card = Card['edit_icon']
                subformat(icon_card)._render_core
              else
                'edit'
              end
            }
          </a>
        }
      end
 
      # show default image if user has no image
      #~~~~~~~~~~~~~~~~~~~~~~
 
 
      view :missing, :ltype=>:user, :right=>:image do |args|
        wrap :missing_image do
          subformat( Card['missing person'] )._render_core
        end
      end
 
      # Customize watching/following.  
      # Too much work for what is really only changing text and hover behavior
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


      view :watch do |args|
        wrap :watch, args do
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

  
      view :watch, :type=>:cardtype do |args|
        wrap :watch, args do
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

 
      # ALL the "branch" stuff is about the special Topics tree
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
      view :closed_branch do |args|
        has_subtopics = Card.exists? "#{card.cardname.trunk_name}+subtopics"
        wrap :closed_branch do
          basic_branch :closed, !!has_subtopics
        end
      end
  
      view :open_branch do |args|
        @paging_params = { :limit=> 1000 }
        subtopics_card = Card.fetch "#{card.cardname.trunk_name}+subtopics+*refer to+unlimited"
        wrap :open_branch do
          basic_branch(:open) + subformat( subtopics_card )._render_content( :item => :closed_branch )
        end
      end
  
  
      # Everything below is about the special navbox behavior
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
      view :raw, :self=>:cp_navbox do |args|
        %{ <form action="#{Card.path_setting '/:search'}" id="navbox-form" method="get">
          #{hidden_field_tag :item, 'cp_result_item' }
          #{text_field_tag :_keyword, '', :class=>'navbox'
          }#{select_tag '_wql[type]', options_for_select([['All Content',nil], 'Foundations', 'Organizations', 'Topics', 'People'])
          }#{submit_tag 'search'}
         </form>}
      end
  
      view :cp_result_item do |args|
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

      view :mmt_confirm, :tags=>:unknown_ok do |args|
        roles = card.who_can(:read).map{ |id| Card[id].name }
        fieldset "confirm permissions", %{
          <div style="text-align: left">
            #{ radio_button_tag 'card[comment_author]', 'restrict', false, :class=>'submitter' } 
            <label>restrict to MMT Staff</label><br/>
            #{ radio_button_tag 'card[comment_author]', 'allow'   , false, :class=>'submitter' }
            <label>do not restrict</label>
          </div>
        },
        :editor => 'mmt_confirm',
        :help   => "<div style='font-weight:normal'>By default, this card will be visible to: #{ roles * ', '}.</div>"
      end

      view :core, :self=>:cp_navbox do |args|
        _render_raw
      end
  
    end
  
  end

end


module Wagn
  class Card::HtmlFormat
    def basic_branch state, show_arrow=true
      arrow_link = case
        when state==:open
          link_to '', path(:view=>"closed_branch"), :title=>"close #{card.name}", :remote=>true,
            :class=>"ui-icon ui-icon-circle-triangle-s toggler slotter"
        when show_arrow
          link_to '',  path(:view=>"open_branch"), :title=>"open #{card.name}", :remote=>true,
            :class=>"ui-icon ui-icon-circle-triangle-e toggler slotter"
        else
          %{ <a href="javascript:void()" class="title branch-placeholder"></a> }
        end
    
      %{ 
        <div class="closed-view">
          <h1 class="card-header">
            #{ arrow_link }
            #{ link_to_page card.cardname.trunk_name, nil, :class=>"branch-direct-link", :title=>"go to #{card.cardname.trunk_name}" }
          </h1> 
          #{ wrap_content(:closed) { render_closed_content } }
        </div>
      }
    end
    def watching_type_cards
      %{<span class="watch-no-toggle">Following all #{ card.type_name.pluralize }</span>}
    end
  end

  class Card::JsonFormat 
    # bit of a hack to make navbox results restrictable
    def goto_wql(term)
      xtra = search_params
      xtra.delete :default_limit
      xtra.merge( { :complete=>term, :limit=>8, :sort=>'name', :return=>'name' } )
    end
  end

  class Card::Format
    #probably need more general handling of WQL add-ons like this
    def params
      @params ||= begin
        p = super
        p.delete('_wql') if p['_wql'] && !p['_wql']['type'].present?
        p
      end      
    end
  end
end
