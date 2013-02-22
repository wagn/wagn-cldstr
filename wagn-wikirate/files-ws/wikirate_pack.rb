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
    
    #alias_view :titled, { :right=>'source_type' }, :missing
  
  end

  
  class Renderer::Html
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