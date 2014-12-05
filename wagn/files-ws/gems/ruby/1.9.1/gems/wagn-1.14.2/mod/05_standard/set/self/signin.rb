
format :html do

  view :open do |args|
    args.merge! :optional_help=>:show
    super args
  end
  
  def default_title_args args
    args[:title] ||= 'Sign In'
  end

  view :open_content do |args|
    # annoying step designed to avoid table of contents.  sigh
    _render_core( args )
  end
  
  view :closed_content do |args|
    ''
  end
  
  
  view :core do |args|
    args[:buttons] = button_tag 'Sign in'
    if Card.new(:type_id=>Card::SignupID).ok? :create
      args[:buttons] += link_to( '...or sign up!', wagn_path("account/signup"))
    end
    args[:buttons] += raw("<div style='float:right'>#{ link_to_view 'RESET PASSWORD', :edit }</div>") #FIXME - hardcoded styling
  
    account = card.fetch :trait=>:account, :new=>{}
  
    form_args = {
      :hidden => { :success=>"REDIRECT: #{interrupted_action || '*previous'}" },
      :recaptcha => :off
    }
  
    with_inclusion_mode :edit do
      card_form :update, form_args do
        [
          Auth.as_bot do
            subformat(account)._render :content_fieldset, :structure=>true, :items=>{:autocomplete=>'on'}
          end, 
          _optional_render( :button_fieldset, args )
        ].join
      end
    end
  end

  #FORGOT PASSWORD
  view :edit do |args|
    args.merge!( {
      :title=>'Forgot Password',
      :optional_help=>:hide,
      :buttons => button_tag( 'Reset my password' ),
      :structure => true,      
      :hidden => { 
        :reset_password => true,
        :success => { :view => :reset_password_success }
      }
    } )
    
    Auth.as_bot { super args }
  end
  
  view :raw do |args|
    '{{+*email|title:email;type:Phrase}}'
  end

  view :reset_password_success do |args|
    frame { 'Check your email for a link to reset your password' }
  end

end

event :signin, :before=>:approve, :on=>:update do 
  email = subcards["+#{Card[:email   ].name}"]
  email &&= email['content']
  pword = subcards["+#{Card[:password].name}"]
  pword &&= pword['content']

  abort :failure, 'bad signin args' unless email && pword  
  
  if signin_id = Auth.authenticate( email, pword )
    Auth.signin signin_id
    abort :success
  else
    accted = Auth[ email.strip.downcase ]
    errors.add :signin, case
      when accted.nil?             ; "Unrecognized email."
      when !accted.account.active? ; "Sorry, that account is not active."
      else                         ; "Wrong password"
      end
    abort :failure
  end  
end

event :send_reset_password_token, :before=>:signin, :on=>:update, :when=>proc{ |c| Env.params[:reset_password] } do
  email = subcards["+#{Card[:email].name}"]
  email &&= email['content']
  
  if accted = Auth[ email.strip.downcase ] and accted.account.active?
    accted.account.send_reset_password_token
    abort :success    
  else
    if accted
      errors.add :account, 'not active'
    else
      errors.add :email, 'not recognized'
    end
    abort :failure
  end
end

event :signout, :before=>:approve, :on=>:delete do
  Auth.signin nil
  abort :success
end


