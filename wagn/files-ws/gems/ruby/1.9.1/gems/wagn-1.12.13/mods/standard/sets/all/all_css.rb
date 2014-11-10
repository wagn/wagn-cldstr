# -*- encoding : utf-8 -*-
    
format :css do

  def get_inclusion_defaults
    { :view => :content }
  end

  def show args
    view = args[:view] || :content
    render view, args
  end
  
  view :titled do |args|
    major_comment( %{ Style Card: "#{ card.name }" } ) +
    _render_core( args )
  end
  
  view :content do |args|
   _render_core( args )
  end
  
  view :missing do |args|
    major_comment "MISSING Style Card: #{card.name}"
  end
  
  view :import do |args|
    %{\n@import url("#{ _render_url :item=>:import }");\n}
  end
  
  view :url, :perms=>:none do |args|
    page_path card.name, :format=>:css, :item=>args[:item]
#    wagn_url _render_linkname
  end

  def major_comment comment, char='-'
    edge = %{/* #{ char * ( comment.length+4 ) } */}
    main = %{/* #{ char } #{ comment } #{ char } */}
    "#{edge}\n#{main}\n#{edge}\n\n"
  end


end
