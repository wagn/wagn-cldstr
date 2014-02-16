# -*- encoding : utf-8 -*-

Rails.application.routes.draw do

  if !Rails.env.production? && Object.const_defined?( :JasmineRails )
    mount Object.const_get(:JasmineRails).const_get(:Engine) => "/specs"
  end
  
  #most common
  root                      :to => 'card#read', :via=>:get
  match "#{ Wagn.config.files_web_path }/:id(-:size)-:rev.:format" => 
                                   'card#read', :via=>:get, :id => /[^-]+/, :explicit_file=>true
  match 'recent(.:format)'      => 'card#read', :via=>:get, :id => '*recent' #obviate by making links use codename
#  match ':view:(:id(.:format))'          => 'card#read', :via=>:get  
  match '(/wagn)/:id(.:format)' => 'card#read', :via=>:get  #/wagn is deprecated
  
  # RESTful
  root              :to => 'card#create', :via=>:post
  root              :to => 'card#update', :via=>:put
  root              :to => 'card#delete', :via=>:delete
  
  match ':id(.:format)' => 'card#create', :via=>:post
  match ':id(.:format)' => 'card#update', :via=>:put
  match ':id(.:format)' => 'card#delete', :via=>:delete

  # legacy                                         
  match 'new/:type'                  => 'card#read', :via=>:get, :view=>'new'
  match 'card/:view(/:id(.:format))' => 'card#read', :via=>:get, :view=> /new|options|edit/
  match 'account/signup'             => 'card#read', :via=>:get, :view=>'new',  :card=>{ :type_code=>:account_request }
  match 'account/accept'             => 'card#read', :via=>:get, :view=>'edit', :card=>{ :type_code=>:account_request }
  match 'account/invite'             => 'card#read', :via=>:get, :view=>'new',  :card=>{ :type_code=>:user            }
  
  # standard non-RESTful
  match ':controller/:action(/:id(.:format))'
  match ':action(/:id(.:format))'        => 'card' 

  # other
  match '*id' => 'card#read', :view => 'bad_address'

end




