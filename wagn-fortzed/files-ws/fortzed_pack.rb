class Wagn::Renderer::Html
  define_view :core, :name=>'pledge_count' do |args|
    User.as :wagbot do
      # would be great to have a better solution for this!
      _final_search_type_core
    end
  end
end