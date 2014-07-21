
format :html do

  view :raw do |args|
    #ENGLISH
    links = []
    if Auth.signed_in?
      links << link_to_page( Auth.current.name, nil, :id=>'my-card-link' )
      links << link_to( 'Sign out', wagn_path('delete/:signin'), :id=>'signout-link' )
      #  if Card.new(:type_id=>Card.default_accounted_type_id).ok? :create
      #    link_to 'Invite a Friend', "#{prefix}/invite", :id=>'invite-a-friend-link'
      #  end
    else
      if Card.new(:type_id=>Card::SignupID).ok? :create
        links << link_to( 'Sign up', wagn_path('account/signup'), :id=>'signup-link' )
      end
      links << link_to( 'Sign in', wagn_path(':signin'), :id=>'signin-link' )
    end
    
    %{<span id="logging">#{ links.join ' ' }</span>}
  end

end
