module Wagn
  module Set::Type::Source
    include Sets
    
    module Model
      def autoname ignore=nil
    #    Rails.logger.info "auto"
        size_limit = 80
    
        %w{ Origin Title Date }.map do |field|
          value = if cards.blank?
              #currently only for migrations
              c = Card["#{self.name}+#{field}"] and c.content
            else
              field = cards[ "~plus~#{field}" ] and field["content"]
            end
          if value.blank?
            errors.add :autoname, "need valid #{field}"
            value = nil
          else
            unwanted_characters_regexp = %{[#{(Wagn::Cardname::BANNED_ARRAY + %w{ [ ] n }).join('\\')}/]}
            value.gsub! /#{unwanted_characters_regexp}/, ''
            if past_size_limit = value[size_limit+1] and past_size_limit =~ /^\S/
              value = value[0..size_limit].gsub /\s+\S*$/, '...'
            end
          end
          value
        end.compact.join ', '
      end
    end


    format :html
    
    define_view :core, :name=>:wikirate_nav do |args|
      result = ''
      main = root.card
      return unless main
      part1 = main.simple? ? main : begin
        partname = '_1'.to_name.to_absolute main.name
        Card[partname]
      end
      if part1 and type_name = part1.type_name and %w{ Market Company }.member?( type_name )
        p1_options = Card.search( :type=> type_name, :sort => :name ).map do |opt|
          [ opt.name, opt.cardname.url_key ]
        end
        result << "<select>#{ options_for_select p1_options, part1.cardname.url_key }</select>"
      
        if !main.simple?
          part2name = '_2'.to_name.to_absolute main.name
          if part2 = Card[part2name] and part2.type_name == 'Topic'

            topics_lineage(part2.name).each_with_index do |ancestor, i|
              crit_options = topics_siblings(ancestor, i).map do |crit|
                [crit.name, "#{part1.name}+#{crit.name}".to_name.url_key]
              end
              result << %{  
                &raquo;
                <select class="topic-select">
                 #{ options_for_select crit_options, "#{part1.name}+#{ancestor}".to_name.url_key }
                </select>
              }
            end
          end
        end
      
        result = %{ <div id="topics-navigation" class="go-to-selected">#{ result }</div> }
      end
      result
    end
  
    define_view :core, :right=>:claim_perspective do |args|
      add_name_context
      _final_core args
    end
  
    define_view :titled, :right=>:source_type do |args|
      ''
    end
  
    define_view :missing, :right=>:source_type do |args|
      ''
    end
    
    define_view :name_editor, :type=>:claim do |args|
      fieldset 'claim', (editor_wrap :name do
         raw( name_field form )
      end), :help=>''
    end
    
    
    
    # ALL the "branch" stuff is about the special Topics tree
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
    define_view :closed_branch do |args|
      wrap :closed_branch do
        basic_branch :closed, show_arrow = branch_has_kids?
      end
    end
  
    define_view :open_branch do |args|
      @paging_params = { :limit=> 1000 }
      subtopics_card = Card.fetch "#{card.cardname.trunk_name}+*children+branch"#{}"+unlimited"
      wrap :open_branch do
        basic_branch(:open) + 
        subrenderer( subtopics_card )._render_content( :item => :closed_branch )
      end
    end
    
    #alias_view :titled, { :right=>'source_type' }, :missing
  
  end

  
  class Renderer::Html
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
          <div class="card-header">
            #{ arrow_link }
            #{ link_to_page branch_name, nil, :class=>"branch-direct-link", :title=>"go to #{branch_name}" }
          </div> 
          #{ wrap_content(:closed) { render_closed_content } }
        </div>
      }
    end
    
    def topics_siblings topic, index
      wql = if index==0
        { :not=> { :referred_to_by=> {:right=>'subtopic'} } }
      else
        { :referred_to_by=>
          { :right=>'subtopic', 
            :left=>
            { :type=>'Topic',
              :right_plus=>['subtopic', {:refer_to=>topic} ]
            }
          }
        }
      end
      
      Card.search( { :type=>'Topic', :sort=>'name' }.merge( wql ) )
    end
  
    def topics_lineage topic
      child = [ topic ]
      c = Card.search :type=>'Topic', :right_plus=>['subtopic', {:refer_to=>topic} ], :return=>'name'
      ancestors = c.empty? ? [] : topics_lineage( c[0] )
      ancestors + child
    end 
  end
end