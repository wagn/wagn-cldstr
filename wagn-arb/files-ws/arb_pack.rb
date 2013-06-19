# -*- encoding : utf-8 -*-
class Card
  module Set::Arb
    extend Set

    format :html do

      view :edit_in_form, :right=>:contact do |args|
        Account.as_bot { _final_edit_in_form args }
      end
    end
  end

end
