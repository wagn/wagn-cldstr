
include Basic

attr_accessor :email

format :html do

  view :setup, :tags=>:unknown_ok, :perms=>lambda { |r| Auth.needs_setup? } do |args|
    args.merge!( {
      :title=>'Welcome, Wagneer!',
      :optional_help=>:show,
      :optional_menu=>:never, 
      :help_text=>'To get started, set up an account.',
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

=begin
def ok_to_create
  unless Auth.needs_setup?
    deny_because "You cannot create a #{type_name} directly; you must create a #{Card[:signup].name} first"
  end
end
=end

event :setup_as_bot, :before=>:check_permissions, :on=>:create, :when=>proc{ |c| Card::Env.params[:setup] } do
  # is this still needed, even with the #ok_to_create call?
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


