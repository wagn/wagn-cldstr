class Wagn::Renderer::Html

  define_view :edit_in_form, :right=>:contact do |args|
    Session.as_bot { _final_edit_in_form args }
  end

end