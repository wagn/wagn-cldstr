module Wagn::Set::Arb
  include Wagn::Sets
  
  format :html

  define_view :edit_in_form, :right=>:contact do |args|
    Account.as_bot { _final_edit_in_form args }
  end

end