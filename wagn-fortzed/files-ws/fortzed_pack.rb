# -*- encoding : utf-8 -*-
module Wagn::Set::FortZed
  extend Wagn::Set
  
  format :html do
  
    view :core, :self=>'pledge_count' do |args|
      Account.as_bot do
        # would be great to have a better solution for this!
        _final_search_type_type_core args
      end
    end
  end
end
