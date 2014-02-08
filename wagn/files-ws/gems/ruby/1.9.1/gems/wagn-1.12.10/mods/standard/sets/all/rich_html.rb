# -*- encoding : utf-8 -*-

format :html do
  
  def show args
    @main_view = args[:view] || args[:home_view]

    if ajax_call?
      view = @main_view || :open
      self.render view, args
    else
      self.render_layout args
    end
  end

  view :layout, :perms=>:none do |args|
    layout_content = get_layout_content args
    process_content layout_content
  end

  view :content do |args|
    wrap args.merge(:slot_class=>'card-content') do
      [
        _optional_render( :menu, args, :hide ),
        _render_core( args )
      ]
    end
  end

  view :titled, :tags=>:comment do |args|
    wrap args do   
      [
        _render_header( args.merge :optional_menu=>:hide ),
        wrap_body( :content=>true ) { _render_core args },
        optional_render( :comment_box, args )
      ]
    end
  end

  view :labeled do |args|
    wrap args do
      [
        _optional_render( :menu, args ),
        "<label>#{ _render_title args }</label>",
        wrap_body( :body_class=>'closed-content', :content=>true ) do
          _render_closed_content args
        end
      ]
    end
  end

  view :title do |args|
    title = fancy_title args[:title]
    title = _optional_render( :title_link, args.merge( :title_ready=>title ), :hide ) || title
    add_name_context
    title
  end

  view :title_link do |args|
    link_to_page (args[:title_ready] || showname(args[:title]) ), card.name
  end

  view :open, :tags=>:comment do |args|
    frame args.merge(:content=>true, :optional_toggle=>:show) do
      [
        _render_open_content( args ),
        optional_render( :comment_box, args )
      ]
    end
  end

  view :toggle do |args|
    verb, adjective, direction = ( args[:toggle_mode] == :close ? %w{ open open e } : %w{ close closed s } )
    
    link_to '', path( :view=>adjective ), 
      :remote => true,
      :title => "#{verb} #{card.name}",
      :class => "#{verb}-icon ui-icon ui-icon-circle-triangle-#{direction} toggler slotter nodblclick"
  end
    

  view :header do |args|
    %{
      <h1 class="card-header">
        #{ _optional_render :toggle, args, :hide }
        #{ _optional_render :title, args }
        #{ _optional_render :menu, args }
      </h1>
    }
  end

  view :menu, :tags=>:unknown_ok do |args|
    disc_tagname = Card.fetch(:discussion, :skip_modules=>true).cardname
    disc_card = unless card.new_card? or card.junction? && card.cardname.tag_name.key == disc_tagname.key
      Card.fetch "#{card.name}+#{disc_tagname}", :skip_virtual=>true, :skip_modules=>true, :new=>{}
    end

    @menu_vars = {
      :self         => card.name,
      :type         => card.type_name,
      :structure    => card.structure && card.template.ok?(:update) && card.template.name,
      :discuss      => disc_card && disc_card.ok?( disc_card.new_card? ? :comment : :read ),
      :piecenames   => card.junction? && card.cardname.piece_names[0..-2].map { |n| { :item=>n.to_s } },
      :related_sets => card.related_sets.map { |name,label| { :text=>label, :path_opts=>{ :current_set => name } } }
    }
    if card.real?
      @menu_vars.merge!({
        :edit      => card.ok?(:update),
        :account   => card.account && card.update_account_ok?,
        :watch     => Account.logged_in? && render_watch,
        :creator   => card.creator.name,
        :updater   => card.updater.name,
        :delete    => card.ok?(:delete) && link_to( 'delete', path(:action=>:delete),
          :class => 'slotter standard-delete', :remote => true, :'data-confirm' => "Are you sure you want to delete #{card.name}?"
        )
      })
    end

    json = html_escape_except_quotes JSON( @menu_vars )
    %{<span class="card-menu-link" data-menu-vars='#{json}'>#{_render_menu_link}</span>}
  end


  view :menu_link do |args|
    '<a class="ui-icon ui-icon-gear"></a>'
  end

  view :type do |args|
    klasses = ['cardtype']
    klass = args[:type_class] and klasses << klass
    link_to_page card.type_name, nil, :class=>klasses
  end

  view :closed do |args|
    frame args.merge(:content=>true, :body_class=>'closed-content', :toggle_mode=>:close, :optional_toggle=>:show ) do
      _optional_render :closed_content, args
    end
  end


  ###---( TOP_LEVEL (used by menu) NEW / EDIT VIEWS )

  view :new, :perms=>:create, :tags=>:unknown_ok do |args|
    frame_and_form :create, args, 'main-success'=>'REDIRECT' do |form|
      [
        _optional_render( :name_fieldset,     args ),
        _optional_render( :type_fieldset,     args ),
        _optional_render( :content_fieldsets, args ),
        _optional_render( :button_fieldset,   args )
      ]
    end  
  end
  

  def default_new_args args    
    hidden = args[:hidden] ||= {}
    hidden[:success] ||= card.rule(:thanks) || '_self'
    hidden[:card   ] ||={}
    
    args[:optional_help] = :show

    # name field / title
    if !params[:name_prompt] and !card.cardname.blank?
      # name is ready and will show up in title
      hidden[:card][:name] ||= card.name
    else
      # name is not ready; need generic title
      args[:title] ||= "New #{ card.type_name unless card.type_id == Card.default_type_id }" #fixme - overrides nest args
      unless card.rule_card :autoname
        # prompt for name
        hidden[:name_prompt] = true unless hidden.has_key? :name_prompt
        args[:optional_name_fieldset] ||= :show
      end
    end
    args[:optional_name_fieldset] ||= :hide

    
    # type field
    if ( !params[:type] and !args[:type] and 
        ( main? || card.simple? || card.is_template? ) and
        Card.new( :type_id=>card.type_id ).ok? :create #otherwise current type won't be on menu
      )
      args[:optional_type_fieldset] = :show
    else
      hidden[:card][:type_id] ||= card.type_id
      args[:optional_type_fieldset] = :hide
    end


    cancel = if main?
      { :class=>'redirecter', :href=>Card.path_setting('/*previous') }
    else
      { :class=>'slotter',    :href=>path( :view=>:missing         ) }
    end
    
    args[:buttons] ||= %{
      #{ submit_tag 'Submit', :class=>'create-submit-button', :disable_with=>'Submitting' }
      #{ button_tag 'Cancel', :type=>'button', :class=>"create-cancel-button #{cancel[:class]}", :href=>cancel[:href] }
    }
    
  end

  
  view :edit, :perms=>:update, :tags=>:unknown_ok do |args|
    frame_and_form :update, args do |form|
      [
        _optional_render( :content_fieldsets, args ),
        _optional_render( :button_fieldset,   args )
      ]
    end
  end

  def default_edit_args args
    args[:optional_help] = :show
    
    args[:buttons] = %{
      #{ submit_tag 'Submit', :class=>'submit-button' }
      #{ button_tag 'Cancel', :class=>'cancel-button slotter', :href=>path, :type=>'button' }
    }
  end
  
  view :edit_name, :perms=>:update do |args|
    frame_and_form( { :action=>:update, :id=>card.id }, args, 'main-success'=>'REDIRECT' ) do
      [
        _render_name_fieldset( args ),
        _optional_render( :confirm_rename, args ),
        _optional_render( :button_fieldset, args )
      ]
    end
  end
  
  view :confirm_rename do |args|
    referers = args[:referers]
    dependents = card.dependents
    wrap args do
      %{
        <h1>Are you sure you want to rename <em>#{card.name}</em>?</h1>
        #{ %{ <h2>This change will...</h2> } if referers.any? || dependents.any? }
        <ul>
          #{ %{<li>automatically alter #{ dependents.size } related name(s). } if dependents.any? }
          #{ %{<li>affect at least #{referers.size} reference(s) to "#{card.name}".} if referers.any? }
        </ul>
        #{ %{<p>You may choose to <em>update or ignore</em> the references.</p>} if referers.any? }
      }
    end
  end

  def default_edit_name_args args
    referers = args[:referers] = card.extended_referencers  
    args[:hidden] ||= {}
    args[:hidden].reverse_merge!(
      :success  => '_self',
      :old_name => card.name,
      :referers => referers.size,
      :card     => { :update_referencers => false }
    )
    args[:buttons] = %{
      #{ submit_tag 'Rename and Update', :class=>'renamer-updater' }
      #{ submit_tag 'Rename', :class=>'renamer' }
      #{ button_tag 'Cancel', :class=>'slotter', :type=>'button', :href=>path(:view=>:edit, :id=>card.id)}
    }
    
  end


  view :edit_type, :perms=>:update do |args|
    frame_and_form :update, args do
    #'main-success'=>'REDIRECT: _self', # adding this back in would make main cards redirect on cardtype changes
      [
        _render_type_fieldset( args ),
        optional_render( :button_fieldset, args )
      ]
    end
  end

  def default_edit_type_args args
    args[:variety] = :edit #YUCK!
    args[:hidden] ||= { :view=>:edit }
    args[:buttons] = %{
      #{ submit_tag 'Submit', :disable_with=>'Submitting' }
      #{ button_tag 'Cancel', :href=>path(:view=>:edit), :type=>'button', :class=>'slotter' }      
    }    
  end
  

  view :missing do |args|
    return '' unless card.ok? :create  #this should be moved into ok_view
    new_args = { :view=>:new, 'card[name]'=>card.name }
    new_args['card[type]'] = args[:type] if args[:type]

    wrap args do
      link_to raw("Add #{ fancy_title args[:title] }"), path(new_args),
        :class=>"slotter missing-#{ args[:denied_view] || args[:home_view]}", :remote=>true
    end
  end

  view :closed_missing, :perms=>:none do |args|
    %{<span class="faint"> #{ showname } </span>}
  end



  
# FIELDSET VIEWS

  view :name_fieldset do |args|
    fieldset 'name', raw( name_field form ), :editor=>'name', :help=>args[:help]
  end

  view :type_fieldset do |args|
    field = if args[:variety] == :edit #FIXME dislike this api -ef
      type_field :class=>'type-field edit-type-field'
    else
      type_field :class=>"type-field live-type-field", :href=>path(:view=>:new), 'data-remote'=>true
    end
    fieldset 'type', field, :editor => 'type', :attribs => { :class=>'type-fieldset'}
  end
  
  
  view :button_fieldset do |args|
    %{
      <fieldset>
        <div class="button-area">
          #{ args[:buttons] }
        </div>
      </fieldset>
    }
  end
  
  view :content_fieldsets do |args|
    %{
      <div class="card-editor editor">
        #{ edit_slot args }
      </div>
    }
  end
  
# FIELD VIEWS
  
  view :editor do |args|
    form.text_area :content, :rows=>3, :class=>'tinymce-textarea card-content', :id=>unique_id
  end



  view :edit_in_form, :perms=>:update, :tags=>:unknown_ok do |args| #fixme.  why is this a view??
    eform = form_for_multi
    content = content_field eform, args.merge( :nested=>true )
    opts = { :editor=>'content', :help=>true, :attribs =>
      { :class=> "card-editor RIGHT-#{ card.cardname.tag_name.safe_key }" }
    }
    if card.new_card?
      content += raw( "\n #{ eform.hidden_field :type_id }" )
    else
      opts[:attribs].merge! :card_id=>card.id, :card_name=>(h card.name)
    end
    fieldset fancy_title( args[:title] ), content, opts
  end


  view :options, :tags=>:unknown_ok do |args|
    current_set = Card.fetch( params[:current_set] || card.related_sets[0][0] )

    frame args do
      %{
        #{ subformat( current_set ).render_content }
        #{
          if card.accountable? && !card.account
            %{
              <div class="new-account-link">
                #{ link_to %{Add a sign-in account for "#{card.name}"}, path(:view=>:new_account),
                   :class=>'slotter new-account-link', :remote=>true }
              </div>
            }
          end
        }
      }
    end
  end


  view :related do |args|
    if rparams = params[:related]
      rcardname = rparams[:name].to_name.to_absolute_name( card.cardname)
      rcard = Card.fetch rcardname, :new=>{}

      nest_args = {
        :view          => ( rparams[:view] || :titled ),
        :optional_help => :show,
        :optional_menu => :show
      }
      
      nest_args[:optional_comment_box] = :show if rparams[:name] == '+discussion' #fixme.  yuck!

      frame args do
        process_inclusion rcard, nest_args
      end
    end
  end

  view :help, :tags=>:unknown_ok do |args|
    text = if args[:help_text]
      args[:help_text]
    else
      setting = card.new_card? ? :add_help : :help
      setting = [ :add_help, { :fallback => :help } ] if setting == :add_help

      if help_card = card.rule_card( *setting ) and help_card.ok? :read
        with_inclusion_mode :normal do
          _final_core args.merge( :structure=>help_card.name )
        end
      end
    end
    %{<div class="instruction">#{raw text}</div>} if text
  end

  view :conflict, :error_code=>409 do |args|
    load_revisions
    wrap args.merge( :slot_class=>'error-view' ) do
      %{<strong>Conflict!</strong><span class="new-current-revision-id">#{@revision.id}</span>
        <div>#{ link_to_page @revision.creator.name } has also been making changes.</div>
        <div>Please examine below, resolve above, and re-submit.</div>
        #{wrap(:conflict) { |args| _render_diff } } }
    end
  end

  view :change do |args|
    wrap args do
      %{
        #{ link_to_page card.name, nil, :class=>'change-card' }
        #{ _optional_render :menu, args, :hide }
        #{
        if rev = card.current_revision and !rev.new_record?
          # this check should be unnecessary once we fix search result bug
          %{<span class="last-update"> #{

            case card.updated_at.to_s
              when card.created_at.to_s; 'added'
              when rev.created_at.to_s;  link_to('edited', path(:view=>:history), :class=>'last-edited', :rel=>'nofollow')
              else; 'updated'
            end} #{

             time_ago_in_words card.updated_at } ago by #{ #ENGLISH
             link_to_page card.updater.name, nil, :class=>'last-editor'}
           </span>}
        end
        }
      }
    end
  end

  view :errors, :perms=>:none do |args|
    #Rails.logger.debug "errors #{args.inspect}, #{card.inspect}, #{caller[0..3]*", "}"
    if card.errors.any?
      wrap args do
        %{ <h2>Problems #{%{ with <em>#{card.name}</em>} unless card.name.blank?}</h2> } +
        card.errors.map { |attrib, msg| "<div>#{attrib.to_s.upcase}: #{msg}</div>" } * ''
      end
    end
  end

  view :not_found do |args| #ug.  bad name.
    sign_in_or_up_links = if !Account.logged_in?
      %{<div>
        #{link_to "Sign In", :controller=>'account', :action=>'signin'} or
        #{link_to 'Sign Up', :controller=>'account', :action=>'signup'} to create it.
       </div>}
    end
    frame args.merge(:title=>'Not Found', :optional_menu=>:never) do
      %{
        <h2>Could not find #{card.name.present? ? "<em>#{card.name}</em>" : 'that'}.</h2>
        #{sign_in_or_up_links}
      }
    end
  end

  view :denial do |args|
    to_task = if task = args[:denied_task]
      %{to #{task} this.}
    else
      'to do that.'
    end

    if !focal?
      %{<span class="denied"><!-- Sorry, you don't have permission #{to_task} --></span>}
    else
      frame args do #ENGLISH below
        message = case
        when task != :read && Wagn.config.read_only
          "We are currently in read-only mode.  Please try again later."
        when Account.logged_in?
          "You need permission #{to_task}"
        else
          or_signup = if Card.new(:type_id=>Card::AccountRequestID).ok? :create
            "or #{ link_to 'sign up', wagn_url('account/signup') }"
          end
          "You have to #{ link_to 'sign in', wagn_url('account/signin') } #{or_signup} #{to_task}"
        end

        %{<h1>Sorry!</h1>\n<div>#{ message }</div>}
      end
    end
  end


  view :server_error do |args|
    %{
    <body>
      <div class="dialog">
        <h1>Wagn Hitch :(</h1>
        <p>Server Error. Yuck, sorry about that.</p>
        <p><a href="http://www.wagn.org/new/Support_Ticket">Add a support ticket</a>
            to tell us more and follow the fix.</p>
      </div>
    </body>
    }
  end

end


