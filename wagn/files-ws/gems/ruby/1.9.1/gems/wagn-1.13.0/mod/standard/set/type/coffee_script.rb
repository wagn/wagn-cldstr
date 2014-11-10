# -*- encoding : utf-8 -*-
require 'coffee-script'
require 'uglifier'

include Machine
include MachineInput

def compile_coffee script
  ::CoffeeScript.compile script
rescue =>e
  e
end

machine_input do 
  Uglifier.compile( compile_coffee format(:format=>:js)._render_raw )
end

store_machine_output :filetype => "js"

def clean_html?
  false
end

def chunk_list  #turn off autodetection of uri's 
                #TODO with the new format pattern this should be handled in the js format
  :inclusion_only
end


format :html do
  view :editor, :mod=>PlainText::HtmlFormat
  
  view :core do |args|
    js = card.compile_coffee _render_raw
    highlighted_js = ::CodeRay.scan( js, :js ).div
    process_content highlighted_js
  end
  
end


format do  
  view :core do |args|
    process_content card.compile_coffee(_render_raw)
  end
end