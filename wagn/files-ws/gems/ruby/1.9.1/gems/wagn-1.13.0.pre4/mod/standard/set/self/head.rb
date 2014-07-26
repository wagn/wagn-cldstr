format :html do

  view :raw do |args|
    %(
      <meta charset="UTF-8">  
      <meta name="viewport" content="width=device-width, initial-scale=1.0"/>    
      #{ head_title     }
      #{ head_buttons     }
      #{ head_stylesheets }
      #{ head_javascript }      
    )
  end
  
  view :core do |args|
    case
    when focal?    ; CGI.escapeHTML _render_raw(args)
    when @mainline ; "(*head)"
    else           ; _render_raw(args)
    end
  end
  
  def head_title
    title = root.card && root.card.name
    title = nil if title.blank?
    title = params[:action] if title=='*placeholder'
    %(<title>#{title ? "#{title} - " : ''}#{ Card.setting :title }</title>) 
  end
  
  def head_buttons
    bits = []
    [:favicon, :logo].each do |name|
      if c = Card[name] and c.type_id == ImageID and !c.content.blank?
        bits << %{<link rel="shortcut icon" href="#{ subformat(c)._render_source :size=>:icon }" />}
        break
      end
    end

    #Universal Edit Button
    if root.card
      if !root.card.new_record? && root.card.ok?(:update)
        bits << %{<link rel="alternate" type="application/x-wiki" title="Edit this page!" href="#{ root.path :view=>:edit }"/>}
      end

      # RSS # move to mods!
      if root.card.type_id == SearchTypeID
        opts = { :format => :rss }
        root.search_params[:vars].each { |key, val| opts["_#{key}"] = val }
        bits << %{<link rel="alternate" type="application/rss+xml" title="RSS" href=#{page_path root.card.name, opts} />}
      end
    end
    bits.join "\n      "
  end
  
  def head_stylesheets
    manual_style = params[:style]
    style_card   = Card[manual_style] if manual_style
    style_card ||= card.rule_card :style
    
    @css_path = if params[:debug] == 'style'
      page_path( style_card.name, :item => :import, :format => :css) 
    elsif style_card
      wagn_path style_card.machine_output_url
    end 
    
    if @css_path
      %{<link href="#{@css_path}" media="all" rel="stylesheet" type="text/css" />}
    end
  end
  
  def head_javascript
    varvals = [
      "window.wagn={rootPath:'#{ Wagn.config.relative_url_root }'}",
      "window.tinyMCEPreInit={base:\"#{wagn_path 'assets/tinymce'}\",query:'3.5.9',suffix:''}" # tinyMCE doesn't load on non-root wagns w/o preinit line
    ]
    Env.recaptcha_on?                                and varvals << "wagn.recaptchaKey='#{Wagn.config.recaptcha_public_key}'"
    c=Card[:double_click] and !Card.toggle c.content and varvals << 'wagn.noDoubleClick=true'
    @css_path                                        and varvals << "wagn.cssPath='#{@css_path}'"
    
    script_card = root.card.rule_card :script
    ie9_card    = Card[:script_html5shiv_printshiv]
    %(#{ javascript_tag do varvals * ';' end  }      
      #{ javascript_include_tag script_card.machine_output_url if script_card }
      <!--[if lt IE 9]>#{ javascript_include_tag ie9_card.machine_output_url if ie9_card }<![endif]-->
      #{ javascript_tag { "wagn.setTinyMCEConfig('#{ escape_javascript Card.setting(:tiny_mce).to_s }')" } }
      #{ google_analytics_head_javascript })
  end
    
  
  def google_analytics_head_javascript
    if ga_key = Card.setting("*google analytics key") #fixme.  escape this?
      %{
        <script type="text/javascript">
          var _gaq = _gaq || [];
          _gaq.push(['_setAccount', '#{ga_key}']);
          _gaq.push(['_trackPageview']);
          (function() {
            var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
            ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
            var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
          })();
        </script>
      }
    end
  end
end


