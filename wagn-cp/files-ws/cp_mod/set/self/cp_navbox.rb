
view :raw do |args|
  %{ <form action="#{Card.path_setting '/:search'}" id="navbox-form" method="get">
    #{hidden_field_tag :item, 'cp_result_item' }
    #{text_field_tag :_keyword, '', :class=>'navbox'
    }#{select_tag '_wql[type]', options_for_select([['All Content',nil], 'Foundations', 'Organizations', 'Topics', 'People'])
    }#{submit_tag 'search'}
   </form>}
end

view :core, :raw