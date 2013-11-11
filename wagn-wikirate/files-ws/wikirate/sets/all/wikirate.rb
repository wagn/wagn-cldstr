
format :html do

  view :cite do |args|
    @parent.vars[:citation_number] ||= 0
    num = @parent.vars[:citation_number] += 1
    %{<a class="citation" href="##{card.cardname.url_key}">#{num}</a>}
  end


  # navdrop views are called by wikirate-nav js
  view :navdrop, :tags=>:unknown_ok do |args|
    items = Card.search( :type_id=>card.type_id, :sort=>:name, :return=>:name ).map do |item|
      klass = item.to_name.key == card.key ? 'class="current-item"' : ''
      %{<li #{ klass }>#{ link_to_page item }</li>}
    end.join "\n"
    %{ <ul>#{items}</ul> }
  end
    

  # TOPIC TREE 
  # this is different from (and pre-dates) the jstree-based topic editor.
  # it's the Topics tree on the main Topics page
  # merits revisiting (and unification?)
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  view :closed_branch do |args|
    wrap :closed_branch do
      basic_branch :closed, show_arrow = branch_has_kids?
    end
  end

  view :open_branch do |args|
    @default_search_params = { :limit=> 1000 }
    subtopics_card = Card.fetch "#{card.cardname.trunk_name}+children+branch"#{}"+unlimited"
    wrap :open_branch do
      basic_branch(:open) + 
      subformat( subtopics_card )._render_content( :item => :closed_branch )
    end
  end


  def basic_branch state, show_arrow=true
    branch_name = card.cardname.trunk
    arrow_link = case
      when state==:open
        link_to_view '', :closed_branch, :title=>"close #{branch_name}", :class=>"ui-icon ui-icon-circle-triangle-s toggler slotter"
      when show_arrow
        link_to_view '', :open_branch, :title=>"open #{branch_name}", :class=>"ui-icon ui-icon-circle-triangle-e toggler slotter"
      else
        %{ <a href="javascript:void()" class="title branch-placeholder"></a> }
      end

    %{ 
      <div class="closed-view">
        <h1 class="card-header">
          #{ arrow_link }
          #{ link_to_page branch_name, nil, :class=>"branch-direct-link", :title=>"go to #{branch_name}" }
        </h1> 
        #{ 
          wrap_body :body_class=>'closed-content', :content=>true do
            render_closed_content
          end          
        }
      </div>
    }
  end

  def branch_has_kids?
    branch_card = card.trunk
    case field = tree_children_field(branch_card.type_name)
    when nil      ; false
    when 'always' ; true
    else Card.exists? "#{branch_card.name}+#{field}"
    end
  end

  # not great naming.  Idea is to be able to see at a glance whether a card has children.
  # if represented as a pointer from the card (eg <topic>+subtopics), then "subtopics" is the val we're going for.
  # otherwise it gets more complex...
  def tree_children_field type_name
    @@tree_children_field ||= {}
    if @@tree_children_field.has_key? type_name
      @@tree_children_field[type_name]
    else
      @@tree_children_field[type_name] = begin
        field = Card.fetch("#{type_name}+*tree children field") and
          field.item_names.first
      end
    end
  end

end



