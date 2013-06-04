# -*- encoding : utf-8 -*-
module Wagn

  module Set::Arb
    extend Wagn::Sets

    format :html

    define_view :edit_in_form, :right=>:contact do |args|
      Account.as_bot { _final_edit_in_form args }
    end
  end

end
