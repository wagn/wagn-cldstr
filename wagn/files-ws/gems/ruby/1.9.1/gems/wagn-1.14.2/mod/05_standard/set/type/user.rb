
include Basic

attr_accessor :email

format :html do

  view :setup, :tags=>:unknown_ok, :perms=>lambda { |r| Auth.needs_setup? } do |args|
    help_text = 'To get started, set up an account.'
    if Wagn.config.action_mailer.perform_deliveries == false 
      help_text += '<br>WARNING: Email delivery is turned off. Change settings in config/application.rb to send sign up notifications.'
    end
    args.merge!( {
      :title=>'Welcome, Wagneer!',
      :optional_help=>:show,
      :optional_menu=>:never, 
      :help_text=>help_text,
      :buttons => button_tag( 'Set up', :disable_with=>'Setting up' ),
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
  # we need bot authority to set the initial administrator roles
  # this is granted and inspected here as a separate event for 
  # flexibility and security when configuring initial setups
end  

event :setup_first_user, :before=>:process_subcards, :on=>:create, :when=>proc{ |c| Card::Env.params[:setup] } do
  subcards['signup alert email+*to'] = name
  subcards['+*roles'] = { :content => Card[:administrator].name }
  
  email, password = subcards.delete('+*account+*email'), subcards.delete('+*account+*password')
  subcards['+*account'] = { '+*email'=>email, '+*password'=>password }
end

event :signin_after_setup, :before=>:extend, :on=>:create, :when=>proc{ |c| Card::Env.params[:setup] } do
  Card.cache.delete Auth::NEED_SETUP_KEY
  Auth.signin id
end


