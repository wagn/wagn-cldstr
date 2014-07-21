# -*- encoding : utf-8 -*-

class Card
  class Format
    include Wagn::Location

    DEPRECATED_VIEWS = { :view=>:open, :card=>:open, :line=>:closed, :bare=>:core, :naked=>:core }
    INCLUSION_MODES  = { :closed=>:closed, :closed_content=>:closed, :edit=>:edit,
      :layout=>:layout, :new=>:edit, :setup=>:edit, :normal=>:normal, :template=>:template } #should be set in views
    
    cattr_accessor :ajax_call, :registered, :max_depth
    [ :perms, :denial_views, :error_codes, :view_tags, :aliases ].each do |acc|
      cattr_accessor acc
      self.send "#{acc}=", {}
    end
    @@max_char_count = 200 #should come from Wagn.config
    @@max_depth      = 20 # ditto
    
    attr_reader :card, :root, :parent, :main_opts
    attr_accessor :form, :error_status, :inclusion_opts
  
    class << self
      @@registered = []

      def register format
        @@registered << format.to_s
      end
    
      def format_class_name format
        f = format.to_s
        f = @@aliases[ f ] || f
        "#{ f.camelize }Format"
      end


      def extract_class_vars view, opts
        return unless opts.present?
        perms[view]       = opts.delete(:perms)      if opts[:perms]
        error_codes[view] = opts.delete(:error_code) if opts[:error_code]
        denial_views[view]= opts.delete(:denial)     if opts[:denial]

        if tags = opts.delete(:tags)
          Array.wrap(tags).each do |tag|
            view_tags[view] ||= {}
            view_tags[view][tag] = true
          end
        end

      end

      def new card, opts={}
        if self != Format
          super
        else
          klass = Card.const_get format_class_name( opts[:format] || :html )
          self == klass ? super : klass.new( card, opts )
        end
      end
    
      def tagged view, tag
        view and tag and view_tags = @@view_tags[view.to_sym] and view_tags[tag.to_sym]
      end
      
      
      def format_ancestry
        ancestry = [ self ]
        unless self == Card::Format
          ancestry = ancestry + superclass.format_ancestry
        end
        ancestry
      end
        
    end
    
    
    #~~~~~ INSTANCE METHODS

    def initialize card, opts={}
      @card = card or raise Card::Error, "format initialized without card"
      opts.each do |key, value|
        instance_variable_set "@#{key}", value
      end

      @mode  ||= :normal
      @depth ||= 0
      @root  ||= self      

      @context_names ||= if params[:slot] && context_name_list = params[:slot][:name_context]
        context_name_list.split(',').map &:to_name
      else [] end
        
      include_set_format_modules
      self
    end
    
    def include_set_format_modules
      self.class.format_ancestry.reverse.each do |klass|
        card.set_format_modules( klass ).each do |m|
          singleton_class.send :include, m
        end
      end
    end
  
    def inclusion_defaults
      @inclusion_defaults ||= begin
        defaults = get_inclusion_defaults.clone
        defaults.merge! @inclusion_opts if @inclusion_opts
        defaults
      end
    end
    
    def get_inclusion_defaults
      { :view => :name }
    end
    
    def params
      Env.params
    end
    
    def controller
      Env[:controller] ||= CardController.new
    end
    
    def session
      Env.session
    end

    def showname title=nil
      if title
        title.to_name.to_absolute_name(card.cardname).to_show *@context_names
      else
        @showname ||= card.cardname.to_show *@context_names
      end
    end
  
    def main?
      @depth == 0
    end

    def focal? # meaning the current card is the requested card
      if Env.ajax?
        @depth == 0
      else
        main?
      end
    end

    def template
      @template ||= begin
        c = controller
        t = ActionView::Base.new c.class.view_paths, {:_routes=>c._routes}, c
        t.extend c.class._helpers
        t
      end
    end

    def method_missing method, *opts, &proc
      case method
      when /(_)?(optional_)?render(_(\w+))?/  
        view = $3 ? $4 : opts.shift      
        args = opts[0] ? opts.shift.clone : {} 
        args.merge!( :optional=>true, :default_visibility=>opts.shift) if $2
        args[ :skip_permissions ] = true if $1
        render view, args           
      when /^_view_(\w+)/
        view = @current_view || $1 
        unsupported_view view
      else
        proc = proc { |*a| raw yield *a } if proc
        response = root.template.send method, *opts, &proc
        String===response ? root.template.raw( response ) : response
      end
    end

    #
    # ---------- Rendering ------------
    #
    
    

    def render view, args={}
      unless args.delete(:optional) && !show_view?( view, args )
        @current_view = view = ok_view canonicalize_view( view ), args       
        args = default_render_args view, args
        with_inclusion_mode view do
          send "_view_#{ view }", args
        end
      end
    rescue => e
      rescue_view e, view
    end

    
    def show_view? view, args
      default = args.delete(:default_visibility) || :show #FIXME - ugly
      view_key = canonicalize_view view
      api_option = args["optional_#{ view_key }".to_sym]
      case 
      # args remove option
      when api_option == :always                   ; true
      when api_option == :never                    ; false
      # wagneer's choice                           
      when show_views( args ).member?( view_key )  ; true
      when hide_views( args ).member?( view_key )  ; false
      # args override default                      
      when api_option == :show                     ; true
      when api_option == :hide                     ; false
      # default                                    
      else                                         ; default==:show
      end        
    end
    
    def show_views args
      parse_view_visibility args[:show]
    end
    
    def hide_views args
      parse_view_visibility args[:hide]
    end
    
    def parse_view_visibility val
      (val || '').split( /[\s\,]+/ ).map { |view| canonicalize_view view }
    end
    

    def default_render_args view, a=nil
      args = case a
      when nil   ; {}
      when Hash  ; a.clone
      when Array ; a[0].merge a[1]
      else       ; raise Card::Error, "bad render args: #{a}"
      end
      
      view_key = canonicalize_view view
      default_method = "default_#{ view }_args"
      if respond_to? default_method
        send default_method, args
      end
      args
    end
    

    def rescue_view e, view
      if Rails.env =~ /^cucumber|test$/
        raise e
      else
        controller.send :notify_airbrake, e if Airbrake.configuration.api_key
        Rails.logger.info "\nError rendering #{error_cardname} / #{view}: #{e.class} : #{e.message}"
        Rails.logger.debug "BT:  #{e.backtrace*"\n  "}"
        rendering_error e, view
      end
    end

    def error_cardname
      card && card.name.present? ? card.name : 'unknown card'
    end
  
    def unsupported_view view
      "view (#{view}) not supported for #{error_cardname}"
    end

    def rendering_error exception, view
      "Error rendering: #{error_cardname} (#{view} view)"
    end

    #
    # ------------- Sub Format and Inclusion Processing ------------
    #

    def subformat subcard
      subcard = Card.fetch( subcard, :new=>{} ) if String===subcard
      sub = self.class.new subcard, :parent=>self, :depth=>@depth+1, :root=>@root,
        # FIXME - the following four should not be hard-coded here.  need a generalized mechanism
        # for attribute inheritance
        :context_names=>@context_names, :mode=>@mode, :mainline=>@mainline, :form=>@form
    end


    def process_content content=nil, opts={}
      process_content_object(content, opts).to_s
    end

    def process_content_object content=nil, opts={}
      return content unless card
      content = card.raw_content || '' if content.nil?

      obj_content = Card::Content===content ? content : Card::Content.new( content, format=self )

      card.update_references( obj_content, refresh=true ) if card.references_expired  # I thik we need this generalized

      obj_content.process_content_object do |chunk_opts|
        prepare_nest chunk_opts.merge(opts) { yield }
      end
    end

    def ok_view view, args={}    
      return view if args.delete :skip_permissions
      approved_view = case
        when @depth >= @@max_depth      ; :too_deep                    # prevent recursion. @depth tracks subformats
        when @@perms[view] == :none     ; view                         # view requires no permissions
        when !card.known? &&
          !tagged( view, :unknown_ok )  ; view_for_unknown view, args  # handle unknown cards (where view not exempt)
        else                            ; permitted_view view, args    # run explicit permission checks
        end

      args[:denied_view] = view if approved_view != view
      if focal? && error_code = @@error_codes[ approved_view ]
        root.error_status = error_code
      end
      approved_view
    end
  
    def tagged view, tag
      self.class.tagged view, tag
    end
  
    def permitted_view view, args
      perms_required = @@perms[view] || :read
      args[:denied_task] =
        if Proc === perms_required
          :read if !(perms_required.call self)  # read isn't quite right
        else
          [perms_required].flatten.find { |task| !ok? task }
        end
      
      if args[:denied_task]
        @@denial_views[view] || :denial
      else
        view
      end
    end
  
    def ok? task
      task = :create if task == :update && card.new_card?
      @ok ||= {}
      @ok[task] = card.ok? task if @ok[task].nil?
      @ok[task]
    end
  
    def view_for_unknown view, args
      # note: overridden in HTML
      focal? ? :not_found : :missing
    end

    def canonicalize_view view
      unless view.blank?
        view_key = view.to_name.key.to_sym
        DEPRECATED_VIEWS[view_key] || view_key
      end
    end
    
    def with_inclusion_mode mode
      if switch_mode = INCLUSION_MODES[ mode ] and @mode != switch_mode
        old_mode, @mode = @mode, switch_mode
        @inclusion_defaults = nil
      end
      result = yield
      if old_mode
        @inclusion_defaults = nil
        @mode = old_mode
      end
      result
    end

    def prepare_nest opts
      @char_count ||= 0
      
      opts ||= {}
      case
      when opts.has_key?( :comment )                            ; opts[:comment]     # as in commented code
      when @mode == :closed && @char_count > @@max_char_count   ; ''                 # already out of view
      when opts[:inc_name]=='_main' && !Env.ajax? && @depth==0  ; expand_main opts
      else
        nested_card = Card.fetch opts[:inc_name], :new=>new_inclusion_card_args(opts)
        result = nest nested_card, opts
        @char_count += result.length if @mode == :closed && result
        result
      end
    end

    def expand_main opts
      opts.merge! root.main_opts if root.main_opts
      legacy_main_opts_tweaks! opts

      opts[:view] ||= :open
      with_inclusion_mode :normal do
        @mainline = true
        result = wrap_main nest( root.card, opts )
        @mainline = false
        result
      end
    end
    
    def legacy_main_opts_tweaks! opts 
      if val=params[:size] and val.present?
        opts[:size] = val.to_sym
      end

      if val=params[:item] and val.present?
        opts[:items] = (opts[:items] || {}).reverse_merge :view=>val.to_sym
      end
    end

    def wrap_main content
      content  #no wrapping in base format
    end

    def nest nested_card, opts={}
      #ActiveSupport::Notifications.instrument('wagn', message: "nest: #{nested_card.name}, #{opts}") do
      opts.delete_if { |k,v| v.nil? }
      opts.reverse_merge! inclusion_defaults
    
      sub = nil
      if opts[:inc_name] =~ /^_(self)?$/
        sub = self
      else
        sub = subformat nested_card
        sub.inclusion_opts = opts[:items] ? opts[:items].clone : {}
      end


      view = canonicalize_view opts.delete :view
      opts[:home_view] = [:closed, :edit].member?(view) ? :open : view
      # FIXME: special views should be represented in view definitions

      view = case
      when @mode == :edit
        if @@perms[view]==:none || nested_card.structure || nested_card.key.blank? # eg {{_self|type}} on new cards
          :blank
        else
          :edit_in_form
        end
      when @mode == :template   ; :template_rule
      when @@perms[view]==:none ; view
      when @mode == :closed     ; !nested_card.known?  ? :closed_missing : :closed_content
      else                      ; view
      end
    
      sub.render view, opts
      #end
    end

    def get_inclusion_content cardname
      content = params[cardname.to_s.gsub(/\+/,'_')]

      # CLEANME This is a hack to get it so plus cards re-populate on failed signups
      if p = params['subcards'] and card_params = p[cardname.to_s]
        content = card_params['content']
      end
      content if content.present?  # why is this necessary? - efm  
                                   # probably for blanks?  -- older/wiser efm
    end

    def new_inclusion_card_args options
      args = { :name=>options[:inc_name], :type=>options[:type], :supercard=>card }
      args.delete(:supercard) if options[:inc_name].strip.blank? # special case.  gets absolutized incorrectly. fix in smartname?
      if options[:inc_name] =~ /^_main\+/
        # FIXME this is a rather hacky (and untested) way to get @superleft to work on new cards named _main+whatever
        args[:name] = args[:name].gsub /^_main\+/, '+'
        args[:supercard] = root.card
      end
      if content=get_inclusion_content(options[:inc_name])
        args[:content]=content
      end
      args
    end
    
    def default_item_view
      :name
    end

    def path opts={}
      pcard = opts.delete(:card) || card
      base = opts[:action] ? "card/#{ opts.delete :action }/" : ''
      if pcard && !pcard.name.empty? && !opts.delete(:no_id) && ![:new, :create].member?(opts[:action]) #generalize. dislike hardcoding views/actions here
        base += ( opts[:id] ? "~#{ opts.delete :id }" : pcard.cardname.url_key )
      end
      query = opts.empty? ? '' : "?#{opts.to_param}"
      wagn_path( base + query )
    end
    #
    # ------------ LINKS ---------------
    #

    def final_link href, opts
      if text = opts[:text]
        "#{text}[#{href}]"
      else
        href
      end
    end

    def build_link href, text=nil
      opts = {:text => text }

      opts[:class] = case href.to_s
        when /^https?:/                      ; 'external-link'
        when /^mailto:/                      ; 'email-link'
        when /^([a-zA-Z][\-+.a-zA-Z\d]*):/   ; $1 + '-link'
        when /^\//
          href = internal_url href[1..-1]    ; 'internal-link'
        else
          return href
          Rails.logger.debug "build_link mistakenly(?) called on #{href}, #{text}"
        end
        
      final_link href, opts
    end

    def card_link name, text, known, type=nil
      text ||= name
      linkname = name.to_name.url_key
      opts = {
        :class => ( known ? 'known-card' : 'wanted-card' ),
        :text  => ( text.to_name.to_show @context_names  )
      }
      if !known
        link_params = {}
        link_params['name'] = name.to_s if name.to_s != linkname
        link_params['type'] = type      if type
        linkname += "?#{ { :card => link_params }.to_param }" if !link_params.empty?
      end
      final_link internal_url( linkname ), opts
    end
  
    def unique_id
      "#{card.key}-#{Time.now.to_i}-#{rand(3)}" 
    end

    def internal_url relative_path
      wagn_path relative_path
    end

    def format_date date, include_time = true
      # Must use DateTime because Time doesn't support %e on at least some platforms
      if include_time
        DateTime.new(date.year, date.mon, date.day, date.hour, date.min, date.sec).strftime("%B %e, %Y %H:%M:%S")
      else
        DateTime.new(date.year, date.mon, date.day).strftime("%B %e, %Y")
      end
    end

    def add_name_context name=nil
      name ||= card.name
      @context_names += name.to_name.part_names
      @context_names.uniq!
    end

  end
end

