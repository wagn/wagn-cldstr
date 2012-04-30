class Wagn::Renderer::Html
  define_view :core, :name=>'wikirate nav' do |args|
    result = ''
    main = root.card
    return unless main
    part1 = main.simple? ? main : begin
      partname = '_1'.to_cardname.to_absolute main.name
      Card[partname]
    end
    if %w{ Industry Company }.member? part1.typename
      select_card = Card["#{part1.typename} Select"]
      select_card.content = part1.name
      result << subrenderer(select_card)._render_editor
      
      if !main.simple?
        part2name = '_2'.to_cardname.to_absolute main.name
        part2 = Card[part2name]
        
        if part2.typename == 'Criterion'

          criteria_lineage(part2.name).each_with_index do |ancestor, i|
            crit_options = criteria_siblings(ancestor, i).map do |crit|
              [crit.name, "#{part1.name}+#{crit.name}".to_cardname.to_url_key]
            end
            result << %{  
              &raquo;
              <select class="criterion-select">
               #{ options_for_select crit_options, "#{part1.name}+#{ancestor}".to_cardname.to_url_key }
              </select>
            }
          end
        end
        
      end
      
      result = %{ <div id="criteria-navigation" class="go-to-selected">#{result}</div> }
    end
    result
  end
  
  def criteria_siblings criterion, index
    wql = if index==0
      { :not=> { :referred_to_by=> {:right=>'subcriteria'} } }
    else
      { :referred_to_by=>
        { :right=>'subcriteria', 
          :left=>
          { :type=>'Criterion',
            :right_plus=>['subcriteria', {:refer_to=>criterion} ]
          }
        }
      }
    end
      
    Card.search( { :type=>'Criterion', :sort=>'name' }.merge( wql ) )
  end
  
  def criteria_lineage criterion
    child = [ criterion ]
    c = Card.search :type=>'Criterion', :right_plus=>['subcriteria', {:refer_to=>criterion} ], :return=>'name'
    ancestors = c.empty? ? [] : criteria_lineage( c[0] )
    ancestors + child
  end 
  
#&laquo;  
end