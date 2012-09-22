class Wagn::Renderer::Html
  define_view :core, :name=>'pledge_count' do |args|
    Session.as :wagn_bot do
      # would be great to have a better solution for this!
      _final_search_type_core args
    end
  end
end