# -*- encoding : utf-8 -*-
require 'timecop'

require_dependency 'card'

class SharedData

  def self.account_args hash
    { "+*account" => { "+*password" =>'joe_pass' }.merge( hash ) }
  end

  def self.add_test_data
    
    Wagn::Cache.reset_global
    Card::Env.reset
    Card::Auth.as_bot

    Card.create! :name=>"Joe User",  :type_code=>'user', :content=>"I'm number two", :subcards=>account_args( '+*email'=>'joe@user.com'  )
    Card.create! :name=>"Joe Admin", :type_code=>'user', :content=>"I'm number one", :subcards=>account_args( '+*email'=>'joe@admin.com' )
    Card.create! :name=>"Joe Camel", :type_code=>'user', :content=>"Mr. Buttz",      :subcards=>account_args( '+*email'=>'joe@camel.com' )

    Card['Joe Admin'].fetch(:trait=>:roles, :new=>{}).items = [ Card::AdministratorID ]

    Card.create! :name=>'signup alert email+*to', :content=>'signups@wagn.org'

    # generic, shared attribute card
    color = Card.create! :name=>"color"
    basic = Card.create! :name=>"Basic Card"

    # data for testing users and account requests

    Card.create! :type_code=>'user', :name=>"No Count", :content=>"I got no account"

    
    Card.create! :name=>"Sample User", :type_code=>'user', :subcards=>account_args('+*email'=>'sample@user.com', '+*password'=>'sample_pass')

    # CREATE A CARD OF EACH TYPE

    Card.create! :type_id=>Card::SignupID, :name=>"Sample Signup" #, :email=>"invitation@request.com"
    #above still necessary?  try commenting out above and 'Sign up' below

    Card::Auth.createable_types.each do |type|
      next if ['User', 'Sign up', 'Set', 'Number'].include? type
      Card.create! :type=>type, :name=>"Sample #{type}"
      Card::Auth.current_id = Card::WagnBotID # need to reset after creating sign up, which changes current_id for extend phase
    end



    # data for role_test.rb

    Card.create! :name=>"u1", :type_code=>'user', :subcards=>account_args('+*email'=>'u1@user.com', '+*password'=>'u1_pass')
    Card.create! :name=>"u2", :type_code=>'user', :subcards=>account_args('+*email'=>'u2@user.com', '+*password'=>'u2_pass')
    Card.create! :name=>"u3", :type_code=>'user', :subcards=>account_args('+*email'=>'u3@user.com', '+*password'=>'u3_pass')

    r1 = Card.create!( :type_code=>'role', :name=>'r1' )
    r2 = Card.create!( :type_code=>'role', :name=>'r2' )
    r3 = Card.create!( :type_code=>'role', :name=>'r3' )
    r4 = Card.create!( :type_code=>'role', :name=>'r4' )

    Card['u1'].fetch( :trait=>:roles, :new=>{} ).items = [ r1, r2, r3 ]
    Card['u2'].fetch( :trait=>:roles, :new=>{} ).items = [ r1, r2, r4 ]
    Card['u3'].fetch( :trait=>:roles, :new=>{} ).items = [ r1, r4, Card::AdministratorID ]

    c1 = Card.create! :name=>'c1'
    c2 = Card.create! :name=>'c2'
    c3 = Card.create! :name=>'c3'

    # cards for rename_test
    # FIXME: could probably refactor these..
    z = Card.create! :name=>"Z", :content=>"I'm here to be referenced to"
    a = Card.create! :name=>"A", :content=>"Alpha [[Z]]"
    b = Card.create! :name=>"B", :content=>"Beta {{Z}}"
    t = Card.create! :name=>"T", :content=>"Theta"
    x = Card.create! :name=>"X", :content=>"[[A]] [[A+B]] [[T]]"
    y = Card.create! :name=>"Y", :content=>"{{B}} {{A+B}} {{A}} {{T}}"
    ab = Card.create! :name => "A+B", :content => "AlphaBeta"

    Card.create! :name=>"One+Two+Three"
    Card.create! :name=>"Four+One+Five"

    # for wql & permissions
    %w{ A+C A+D A+E C+A D+A F+A A+B+C }.each do |name| Card.create!(:name=>name)  end
    Card.create! :type_code=>'cardtype', :name=>"Cardtype A", :codename=>"cardtype_a"
    Card.create! :type_code=>'cardtype', :name=>"Cardtype B", :codename=>"cardtype_b"
    Card.create! :type_code=>'cardtype', :name=>"Cardtype C", :codename=>"cardtype_c"
    Card.create! :type_code=>'cardtype', :name=>"Cardtype D", :codename=>"cardtype_d"
    Card.create! :type_code=>'cardtype', :name=>"Cardtype E", :codename=>"cardtype_e"
    Card.create! :type_code=>'cardtype', :name=>"Cardtype F", :codename=>"cardtype_f"

    Card.create! :name=>'basicname', :content=>'basiccontent'
    Card.create! :type_code=>'cardtype_a', :name=>"type-a-card", :content=>"type_a_content"
    Card.create! :type_code=>'cardtype_b', :name=>"type-b-card", :content=>"type_b_content"
    Card.create! :type_code=>'cardtype_c', :name=>"type-c-card", :content=>"type_c_content"
    Card.create! :type_code=>'cardtype_d', :name=>"type-d-card", :content=>"type_d_content"
    Card.create! :type_code=>'cardtype_e', :name=>"type-e-card", :content=>"type_e_content"
    Card.create! :type_code=>'cardtype_f', :name=>"type-f-card", :content=>"type_f_content"

    #warn "current user #{User.session_user.inspect}.  always ok?  #{Card::Auth.always_ok?}"
    c = Card.create! :name=>'revtest', :content=>'first'
    c.update_attributes! :content=>'second'
    c.update_attributes! :content=>'third'
    #Card.create! :type_code=>'cardtype', :name=>'*priority'

    # for template stuff
    Card.create! :type_id=>Card::CardtypeID, :name=> "UserForm"
    Card.create! :name=>"UserForm+*type+*structure", :content=>"{{+name}} {{+age}} {{+description}}"

    Card::Auth.current_id = Card['joe_user'].id
    Card.create!( :name=>"JoeLater", :content=>"test")
    Card.create!( :name=>"JoeNow", :content=>"test")

    Card::Auth.current_id = Card::WagnBotID
    Card.create!(:name=>"AdminNow", :content=>"test")

    Card.create :name=>'Cardtype B+*type+*create', :type=>'Pointer', :content=>'[[r1]]'

    Card.create! :type=>"Cardtype", :name=>"Book"
    Card.create! :name=>"Book+*type+*structure", :content=>"by {{+author}}, design by {{+illustrator}}"
    Card.create! :name => "Iliad", :type=>"Book"


    ### -------- Notification data ------------
    Timecop.freeze(Wagn.future_stamp - 1.day) do
      # fwiw Timecop is apparently limited by ruby Time object, which goes only to 2037 and back to 1900 or so.
      #  whereas DateTime can represent all dates.

      Card.create! :name=>"John", :type_code=>'user', :subcards=>account_args('+*email'=>'john@user.com', '+*password'=>'john_pass')
      Card.create! :name=>"Sara", :type_code=>'user', :subcards=>account_args('+*email'=>'sara@user.com', '+*password'=>'sara_pass')
      
      Card.create! :name => "All Eyes On Me"
      Card.create! :name => "No One Sees Me"
      Card.create! :name => "Sara Following"
      Card.create! :name => "John Following", :content => "{{+her}}"
      Card.create! :name => "John Following+her"
      Card.create! :name => "Optic", :type => "Cardtype"
      Card.create! :name => "Sunglasses", :type=>"Optic", :content=>"{{+tint}}"
      Card.create! :name => "Sunglasses+tint"
      Card.create! :name => "Google glass", :type=>"Optic"
      
      Card.create! :name => "Sara+*following",  :content => "[[Sara Following]]\n[[All Eyes On Me]]\n[[Optic]]\n[Google glass]"
      Card.create! :name => "John+*following",  :content => "[[John Following]]\n[[All Eyes On Me]]"      
    end


    ## --------- create templated permissions -------------
    ctt = Card.create! :name=> 'Cardtype E+*type+*default'


    ## --------- Fruit: creatable by anon but not readable ---
    f = Card.create! :type=>"Cardtype", :name=>"Fruit"
    Card.create! :name=>'Fruit+*type+*create', :type=>'Pointer', :content=>'[[Anyone]]'
    Card.create! :name=>'Fruit+*type+*read', :type=>'Pointer', :content=>'[[Administrator]]'

    # codenames for card_accessor tests
    Card.create! :name=>'*write', :codename=>:write

    # -------- For toc testing: ------------

    Card.create! :name=>"OnneHeading", :content => "<h1>This is one heading</h1>\r\n<p>and some text</p>"
    Card.create! :name=>'TwwoHeading', :content => "<h1>One Heading</h1>\r\n<p>and some text</p>\r\n<h2>And a Subheading</h2>\r\n<p>and more text</p>"
    Card.create! :name=>'ThreeHeading', :content =>"<h1>A Heading</h1>\r\n<p>and text</p>\r\n<h2>And Subhead</h2>\r\n<p>text</p>\r\n<h1>And another top Heading</h1>"

    # -------- For history testing: -----------
    first = Card.create! :name=>"First", :content => 'egg'
    first.update_attributes! :content=> 'chicken'
    first.update_attributes! :content=> 'chick'

  end
end
