# -*- encoding : utf-8 -*-
module Card::Set::WagnOrg

  extend Card::Set
  format :html do
  
    view :shade do |args|
      wrap args do
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

end
