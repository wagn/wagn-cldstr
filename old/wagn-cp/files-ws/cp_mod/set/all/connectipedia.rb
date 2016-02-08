Card.error_codes[:mmt_confirm] = [ :mmt_confirm, 422 ]

event :propose_mmt_restriction, :after=>:store, :on=>:create do
  role_name = 'MMT staff'
  if !@supercard and
    !Auth.always_ok? and                                                             # user is not admin
    Auth.as_card.fetch(:trait=>:roles, :new=>{}).item_names.member?( role_name ) and # user is mmt staff
    who_can(:read) != [ Card[role_name].id ]                                       # card is not already restricted to MMT Staff

    case comment_author #KLUDGE!!! using this to hold restriction info.  need to figure out how to get params through.
    when nil
      self.errors.add :mmt_confirm, 'mmt confirm'
      raise ActiveRecord::Rollback, "kludge"
    when 'restrict'
      Auth.as_bot do
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
  
  
  

  # Special titled view.  Much of this is probably reusable
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  view :titled do |args|
    edit_link = type_link = ''
  
    if main?
      @@displayed_type_ids ||= %w{ Foundations Topic Organization Person Opportunity State County City }.map { |n| Card[n].id }
      if @@displayed_type_ids.member? card.type_id
        type_link = card_link card.type_name, :class=>"cp-typelink cp-type-#{ Card::Codename[ card.type_id ] }" 
      end
    end

    wrap args do
      %{
        <div class="cp-titled-header">
          <div class="cp-titled-right">
            #{ render_watch if main? }
            #{ optional_render :menu, args }
          </div>
          <div class="cp-title">
            #{ type_link }
            #{ _render_title args }
          </div>
        </div>
        #{ wrap_body( :content=>true ) { _render_core args } }
        #{ render_comment_box }
      }
    end
  end

  view :menu_link, :perms=>:update, :denial=>:blank do |args|
    text = if icon_card = Card['edit_icon']
      subformat(icon_card)._render_core
    else
      'edit'
    end
    %{<a>#{ text }</a>}
  end



  # Customize watching/following.  


  def watching_type_cards
    %{<span class="watch-no-toggle">Following all #{ card.type_name.pluralize }</span>}
  end
  

  # ALL the "branch" stuff is about the special Topics tree
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  view :closed_branch do |args|
    has_subtopics = Card.exists? "#{card.cardname.trunk_name}+subtopics"
    wrap args do
      basic_branch :closed, !!has_subtopics
    end
  end

  view :open_branch do |args|
    @default_search_params = { :limit=> 1000 }
    subtopics_card = Card.fetch "#{card.cardname.trunk_name}+subtopics+*refer to+unlimited"
    wrap args do
      basic_branch(:open) + subformat( subtopics_card )._render_content( :item => :closed_branch )
    end
  end


  # Everything below is about the special navbox behavior
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  view :cp_result_item do |args|
    wrap args do
      %{
      <hr>
      <div class="cp-result-top">
        <span class="cp-item-name">
          #{ card_link card.name, :text=>fancy_title }
        </span>
        <span class="cp-item-date">
          #{ time_ago_in_words card.updated_at } ago
        </span>
        <span class="cp-item-type">
          #{ card_link card.type_name }
        </span>
      </div>
      <div class="cp-item-content">
        <div class="closed-content">#{ _render_closed_content }</div>
      </div>
      }
    end
  end


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
          #{ card_link card.cardname.trunk_name, :class=>"branch-direct-link", :title=>"go to #{card.cardname.trunk_name}" }
        </h1>
        #{ 
          wrap_body :body_class=>'closed-content', :content=>true do
            render_closed_content
          end          
        }
      </div>
    }
  end
  
end


format do
  def params
    @params ||= begin
      p = super
      p.delete('_wql') if p['_wql'] && !p['_wql']['type'].present?
      p
    end
  end
end

