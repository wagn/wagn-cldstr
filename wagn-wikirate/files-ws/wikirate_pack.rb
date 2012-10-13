module Wagn::Set::Type::Source
  def autoname name
#    Rails.logger.info "auto"
    size_limit = 80
    
    %w{ Origin Title Date }.map do |name|
      field = cards[ "~plus~#{name}" ]
      value = !field ? nil : field["content"]
      if value.blank?
        errors.add :autoname, "need valid #{name}"
        value = nil
      else
        unwanted_characters_regexp = %{[#{(Wagn::Cardname::BANNED_ARRAY + %w{ [ ] n }).join('\\')}/]}
        value.gsub! /#{unwanted_characters_regexp}/, ''
        if past_size_limit = value[size_limit+1] and past_size_limit =~ /^\S/
          value = value[0..size_limit].gsub /\s+\S*$/, '...'
        end
      end
      value
      name=="Title" ? "<em>#{value}</em>" : value
    end.compact.join ', '
  end
end


class Wagn::Renderer::Html
  define_view :core, :name=>:wikirate_nav do |args|
    result = ''
    main = root.card
    return unless main
    part1 = main.simple? ? main : begin
      partname = '_1'.to_cardname.to_absolute main.name
      Card[partname]
    end
    if part1 and type_name = part1.type_name and %w{ Market Company }.member?( type_name )
      p1_options = Card.search( :type=> type_name, :sort => :name ).map do |opt|
        [ opt.name, opt.cardname.to_url_key ]
      end
      result << "<select>#{ options_for_select p1_options, part1.cardname.to_url_key }</select>"
      
      if !main.simple?
        part2name = '_2'.to_cardname.to_absolute main.name
        if part2 = Card[part2name] and part2.type_name == 'Topic'

          topics_lineage(part2.name).each_with_index do |ancestor, i|
            crit_options = topics_siblings(ancestor, i).map do |crit|
              [crit.name, "#{part1.name}+#{crit.name}".to_cardname.to_url_key]
            end
            result << %{  
              &raquo;
              <select class="topic-select">
               #{ options_for_select crit_options, "#{part1.name}+#{ancestor}".to_cardname.to_url_key }
              </select>
            }
          end
        end
        
      end
      
      result = %{ <div id="topics-navigation" class="go-to-selected">#{result}</div> }
    end
    result
  end
  
  
  define_view :titled, :right=>:source_type do |args|
    ''
  end
  define_view :missing, :right=>:source_type do |args|
    ''
  end
  
  #alias_view :titled, { :right=>'source_type' }, :missing
  
  
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
  
#&laquo;  
end