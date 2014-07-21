
include Basic

attr_accessor :email

format :html do
  #FIXME - should perms check permission to create account?
  view :new do |args|
    args.merge!(
      :title=>'Invite', 
      :optional_help=>:show, 
      :optional_menu=>:never 
    )
    args[:hidden].merge! :card => { :type_id => card.type_id }
    frame_and_form :create, args do
      %{
        #{ _render_name_fieldset :help=>'usually first and last name'   }
        #{# _render_email_fieldset                                       
        }
        #{# _render_invitation_field                                     
        }
      }
    end
  end


  view :setup, :tags=>:unknown_ok, :perms=>lambda { |r| Auth.needs_setup? } do |args|
    args.merge!( {
      :title=>'Welcome, Wagneer!',
      :optional_help=>:show,
      :optional_menu=>:never, 
      :help_text=>'To get started, set up an account.',
      :buttons => button_tag( 'Submit' ),
      :hidden => { 
        :success => "REDIRECT: #{ Card.path_setting '/' }",
        'card[type_id]' => Card.default_accounted_type_id,
        'setup'=>true
      }
    } )

    account = card.fetch :trait=>:account, :new=>{}

    Auth.as_bot do
      frame_and_form :create, args do
        [
          _render_name_fieldset( :help=>'usually first and last name' ),
          subformat(account)._render( :content_fieldset, :structure=>true ), 
          _render_button_fieldset( args )
        ]
      end
    end
  end
end

event :setup_as_bot, :before=>:check_permissions, :on=>:create, :when=>proc{ |c| Card::Env.params[:setup] } do
  abort :failure unless Auth.needs_setup?
  Auth.as_bot
end  

event :setup_first_user, :before=>:process_subcards, :on=>:create, :when=>proc{ |c| Card::Env.params[:setup] } do
  subcards['*request+*to'] = subcards['+*account+*email']
  subcards['+*roles'] = { :content => Card[:administrator].name }
  
  email, password = subcards.delete('+*account+*email'), subcards.delete('+*account+*password')
  subcards['+*account'] = { '+*email'=>email, '+*password'=>password }
end

event :signin_after_setup, :before=>:extend, :on=>:create, :when=>proc{ |c| Card::Env.params[:setup] } do
  Card.cache.delete Auth::NEED_SETUP_KEY
  Auth.signin id
end


