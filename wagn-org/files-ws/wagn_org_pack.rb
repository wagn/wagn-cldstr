# -*- encoding : utf-8 -*-
module Wagn::Set::WagnOrg

  extend Wagn::Sets
  format :html
  
  define_view :shade do |args|
    wrap :shade, args do
      %{
        <h1>
          <a href="#" class="ui-icon ui-icon-triangle-1-e"></a>
          <a class="shade-link">#{ fancy_title }</a>
        </h1>
        <div class="shade-content">#{ render_core }</div>
      }
    end
  end


end
