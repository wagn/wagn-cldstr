
class Card
  class Query
    class CardSpec < Spec
    
      ATTRIBUTES = {
        :basic           => %w{ name type_id content id key updater_id left_id right_id creator_id updater_id codename },
        :relational      => %w{ type part left right editor_of edited_by last_editor_of last_edited_by creator_of created_by member_of member },
        :plus_relational => %w{ plus left_plus right_plus },
        :ref_relational  => %w{ refer_to referred_to_by link_to linked_to_by include included_by },
        :conjunction     => %w{ and or all any },
        :special         => %w{ found_by not sort match complete extension_type },
        :ignore          => %w{ prepend append view params vars size }
      }.inject({}) {|h,pair| pair[1].each {|v| h[v.to_sym]=pair[0] }; h }
    
      DEFAULT_ORDER_DIRS =  { :update => "desc", :relevance => "desc" }
      CONJUNCTIONS = { :any=>:or, :in=>:or, :or=>:or, :all=>:and, :and=>:and }
    
      attr_reader :sql, :query, :rawspec, :selfname
      attr_accessor :joins

      class << self
        def build query
          cardspec = self.new query
          cardspec.merge cardspec.rawspec
        end
      end

      def initialize query
        @mods = MODIFIERS.clone
        @spec, @joins = {}, {}
        @selfname, @parent = '', nil
        @sql = SqlStatement.new

        @query = query.clone
        @query.merge! @query.delete(:params) if @query[:params]
        @vars = @query.delete(:vars) || {}
        @vars.symbolize_keys!
        @query = clean(@query)
        @rawspec = @query.deep_clone

        self
      end


      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # QUERY CLEANING - strip strings, absolutize names, interpret contextual parameters
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    

      def clean query
        query = query.symbolize_keys
        if s = query.delete(:context) then @selfname = s end
        if p = query.delete(:_parent) then @parent   = p end
        query.each do |key,val|
          query[key] = clean_val val
        end
        query
      end

      def clean_val val
        case val
        when String
          if val =~ /^\$(\w+)$/
            val = @vars[$1.to_sym].to_s.strip
          end
          absolute_name val
        when Card::Name             ; clean_val val.s
        when Hash                   ; clean val
        when Array                  ; val.map { |v| clean_val v }
        when Integer, Float, Symbol ; val
        else                        ; raise BadQuery, "unknown WQL value type: #{val.class}"
        end
      end
    
      def root
        @parent ? @parent.root : self
      end
    
      def absolute_name name
        name =~ /\b_/ ? name.to_name.to_absolute(root.selfname) : name
      end


      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # MERGE - reduce query to basic attributes and SQL subconditions
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    

      def merge s
        s = hashify s
        translate_to_attributes s
        ready_to_sqlize s
        @spec.merge! s
        self
      end
  
      def hashify s
        case s
          when String;   { :key => s.to_name.key }
          when Integer;  { :id => s              }
          when Hash;     s
          else; raise BadQueyr, "Invalid cardspec args #{s.inspect}"
        end
      end

      def translate_to_attributes spec
        content = nil
        spec.each do |key,val|
          if key == :_parent
            @parent = spec.delete(key)
          elsif OPERATORS.has_key?(key.to_s) && !ATTRIBUTES[key]
            spec.delete(key)
            content = [key,val]
          elsif MODIFIERS.has_key?(key)
            next if spec[key].is_a? Hash
            val = spec.delete key
            @mods[key] = Array === val ? val : val.to_s
          end
        end
        spec[:content] = content if content
      end


      def ready_to_sqlize spec
        spec.each do |key,val|
          keyroot = field_root(key).to_sym
          if keyroot==:cond                            # internal SQL cond (already ready)
          elsif ATTRIBUTES[keyroot] == :basic          # sqlize knows how to handle these keys; just process value
            spec[key] = ValueSpec.new(val, self)
          else                                         # keys need additional processing
            val = spec.delete key
            is_array = Array===val
            case ATTRIBUTES[keyroot]
              when :ignore                               #noop         
              when :relational, :special, :conjunction ; relate is_array, keyroot, val, :send
              when :ref_relational                     ; relate is_array, keyroot, val, :refspec
              when :plus_relational
                # Arrays can have multiple interpretations for these, so we have to look closer...
                subcond = is_array && ( Array===val.first || conjunction(val.first) )
            
                                                         relate subcond, keyroot, val, :send
              else                                     ; raise BadQuery, "Invalid attribute #{key}"
            end
          end
        end
  
      end
  
      def relate subcond, key, val, method
        if subcond
          conj = conjunction( val.first ) ? conjunction( val.shift ) : :and
          if conj == current_conjunction                # same conjunction as container, no need for subcondition
            val.each { |v| send method, key, v }
          else
            send conj, val.inject({}) { |h,v| h[field key] = v; h }  # subcondition
          end
        else
          send method, key, val
        end
      end

      def refspec key, cardspec
        if cardspec == '_none'
          key = :link_to_missing
          cardspec = 'blank'
        end
        cardspec = CardSpec.build(:return=>'id', :_parent=>self).merge(cardspec)
        merge field(:id) => ValueSpec.new(['in',RefSpec.new( key, cardspec )], self)
      end


      def conjunction val
        if [String, Symbol].member? val.class
          CONJUNCTIONS[val.to_sym]
        end
      end


      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # ATTRIBUTE METHODS - called during merge
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    

      #~~~~~~ RELATIONAL

      def type val
        merge field(:type_id) => id_or_subspec(val)
      end

      def part val
        right = Integer===val ? val : val.clone
        subcondition :left=>val, :right=>right, :conj=>:or
      end

      def left val
        merge field(:left_id) => id_or_subspec(val)
      end
    
      def right val
        merge field(:right_id) => id_or_subspec(val)
      end

      def editor_of val
        revision_spec :creator_id, :card_id, val
      end

      def edited_by val
        revision_spec :card_id, :creator_id, val
      end
  
      def last_editor_of val
        merge field(:id) => subspec(val, :return=>'updater_id')
      end

      def last_edited_by val
        merge field(:updater_id) => id_or_subspec(val)
      end    

      def creator_of val
        merge field(:id)=>subspec(val,:return=>'creator_id')
      end

      def created_by val
        merge field(:creator_id) => id_or_subspec(val)
      end

      def member_of val
        merge field(:right_plus) => [RolesID, {:refer_to=>val}]
      end
  
      def member val
        merge field(:referred_to_by) => {:left=>val, :right=>RolesID }
      end


      #~~~~~~ PLUS RELATIONAL

      def left_plus(val)
        part_spec, junc_spec = val.is_a?(Array) ? val : [ val, {} ]
        merge( field(:id) => subspec(junc_spec, :return=>'right_id', :left =>part_spec))
      end

      def right_plus(val)
        part_spec, junc_spec = val.is_a?(Array) ? val : [ val, {} ]
        merge( field(:id) => subspec(junc_spec, :return=>'left_id', :right=> part_spec ))
      end

      def plus(val)
        subcondition( { :left_plus=>val, :right_plus=>val.deep_clone }, :conj=>:or )
      end
    
    
      #~~~~~~~  CONJUNCTION
    
      def and val
        subcondition val
      end
      alias :all :and
  
      def or val
        subcondition val, :conj=>:or
      end
      alias :any :or
    
      #~~~~~~ SPECIAL


      def found_by val
      
        cards = if Hash===val
          Query.new(val).run
        else
          Array.wrap(val).map do |v|
            Card.fetch absolute_name(val), :new=>{}
          end
        end

        cards.each do |c|
          unless c && [SearchTypeID,SetID].include?(c.type_id)
            raise BadQuery, %{"found_by" value needs to be valid Search card}
          end
          found_by_spec = CardSpec.new(c.get_spec).rawspec
          merge(field(:id) => subspec(found_by_spec))
        end
      end
  
      def not val
        merge field(:id) => subspec( val, {:return=>'id'}, negate=true )
      end

      def sort val
        return nil if @parent
        val[:return] = val[:return] ? safe_sql(val[:return]) : 'content'
        @mods[:sort] =  "t_sort.#{val[:return]}"
        item = val.delete(:item) || 'left'

        if val[:return] == 'count'
          cs_args = { :return=>'count', :group=>'sort_join_field' }
          @mods[:sort] = "coalesce(#{@mods[:sort]},0)"
          case item
          when 'referred_to'
            join_field = 'id'
            cs = CardSpec.build cs_args.merge( field(:cond)=>SqlCond.new("referer_id in #{CardSpec.build( val.merge(:return=>'id')).to_sql}") )
            cs.add_join :wr, :card_references, :id, :referee_id
          else
            raise BadQuery, "count with item: #{item} not yet implemented"
          end
        else
          join_field = case item
            when 'left'  ; 'left_id'
            when 'right' ; 'right_id'
            else         ;  raise BadQuery, "sort item: #{item} not yet implemented"
          end
          cs = CardSpec.build(val)
        end

        cs.sql.fields << "#{cs.table_alias}.#{join_field} as sort_join_field"
        add_join :sort, cs.to_sql, :id, :sort_join_field, :side=>'LEFT'
      end

      def match(val)
        cxn, val = match_prep val
        val.gsub! /[^#{Card::Name::OK4KEY_RE}]+/, ' '
        return nil if val.strip.empty?
    

        cond = begin
          join_alias = add_revision_join
          # FIXME: OMFG this is ugly
          val_list = val.split(/\s+/).map do |v|
            name_or_content = ["replace(#{self.table_alias}.name,'+',' ')","#{join_alias}.content"].map do |field|
              %{#{field} #{ cxn.match quote("[[:<:]]#{v}[[:>:]]") }}
            end
            "(#{name_or_content.join ' OR '})"
          end
          "(#{val_list.join ' AND '})"
        end

        merge field(:cond)=>SqlCond.new(cond)
      end
    
    
      def complete(val)
        no_plus_card = (val=~/\+/ ? '' : "and right_id is null")  #FIXME -- this should really be more nuanced -- it breaks down after one plus
        merge field(:cond) => SqlCond.new(" lower(name) LIKE lower(#{quote(val.to_s+'%')}) #{no_plus_card}")
      end

      def extension_type val
        # DEPRECATED!!!       
        add_join :usr, :users, :id, :card_id
      end
    

      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # ATTRIBUTE METHOD HELPERS - called by attribute methods above
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


      def table_alias
        case
        when @mods[:return]=='condition'
          @parent ? @parent.table_alias : "t"
        when @parent
          @parent.table_alias + "x"
        else 
          "t"
        end
      end

      def add_join(name, table, cardfield, otherfield, opts={})
        join_alias = "#{table_alias}_#{name}"
        @joins[join_alias] = "#{opts[:side]} JOIN #{table} AS #{join_alias} ON #{table_alias}.#{cardfield} = #{join_alias}.#{otherfield}"
        join_alias
      end

      def add_revision_join
        add_join(:rev, :card_revisions, :current_revision_id, :id)
      end

      def field name
        @fields ||= {}
        @fields[name] ||= 0
        @fields[name] += 1
        "#{ name }:#{ @fields[name] }"
      end

      def field_root key
        key.to_s.gsub /\:\d+/, ''
      end

      def subcondition(val, args={})
        args = { :return=>:condition, :_parent=>self }.merge(args)
        cardspec = CardSpec.build( args )
        merge field(:cond) => cardspec.merge(val)
        self.joins.merge! cardspec.joins
        self.sql.relevance_fields += cardspec.sql.relevance_fields
      end


      def revision_spec(field, linkfield, val)
        card_select = CardSpec.build(:_parent=>self, :return=>'id').merge(val).to_sql
        add_join :ed, "(select distinct #{field} from card_revisions where #{linkfield} in #{card_select})", :id, field
      end


      def subspec(spec, additions={ :return=>'id'}, negate=false)
        additions = additions.merge(:_parent=>self)
        operator = negate ? 'not in' : 'in'
        ValueSpec.new([operator,CardSpec.build(additions).merge(spec)], self)
      end

      def id_or_subspec spec
        id = case spec
          when Integer ; spec
          when String  ; Card.fetch_id(spec)
          end
        id or subspec spec
      end
    
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # SQL GENERATION - translate merged hash into complete SQL statement.
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


      def to_sql *args
        sql.conditions << basic_conditions

        return "(" + sql.conditions.last + ")" if @mods[:return]=='condition'
    
        if pconds = permission_conditions
          sql.conditions << pconds
        end

        sql.fields.unshift fields_to_sql
        sql.order = sort_to_sql  # has side effects!
        sql.tables = "cards #{table_alias}"
        sql.joins += @joins.values

        sql.conditions << "#{table_alias}.trash is false"
      
        unless @parent or @mods[:return]=='count'
          sql.group = "GROUP BY #{safe_sql(@mods[:group])}" if !@mods[:group].blank?
          if @mods[:limit].to_i > 0
            sql.limit  = "LIMIT #{  @mods[:limit ].to_i }"
            sql.offset = "OFFSET #{ @mods[:offset].to_i }" if !@mods[:offset].blank?
          end
        end

        sql.to_s
      end
  
      def basic_conditions
        @spec.map { |key, val| val.to_sql field_root(key) }.join " #{ current_conjunction } "
      end
  
      def current_conjunction
        @mods[:conj].blank? ? :and : @mods[:conj]
      end
    
      def permission_conditions
        unless Account.always_ok? #or ( Card::Query.root_perms_only && !root? )
          read_rules = Account.as_card.read_rules
          read_rule_list = read_rules.nil? ? 1 : read_rules.join(',')
          "(#{table_alias}.read_rule_id IN (#{ read_rule_list }))"
        end      
      end

      def fields_to_sql
        field = @mods[:return]
        case (field.blank? ? :card : field.to_sym)
        when :raw;  "#{table_alias}.*"
        when :card; "#{table_alias}.name"
        when :count; "coalesce(count(*),0) as count"
        when :content
          join_alias = add_revision_join
          "#{join_alias}.content"
        else
          ATTRIBUTES[field.to_sym]==:basic ? "#{table_alias}.#{field}" : safe_sql(field)
        end
      end

      def sort_to_sql
        #fail "order_key = #{@mods[:sort]}, class = #{order_key.class}"
    
        return nil if @parent or @mods[:return]=='count' #FIXME - extend to all root-only clauses
        order_key ||= @mods[:sort].blank? ? "update" : @mods[:sort]
    
        order_directives = [order_key].flatten.map do |key|
          dir = @mods[:dir].blank? ? (DEFAULT_ORDER_DIRS[key.to_sym]||'asc') : safe_sql(@mods[:dir]) #wonky
          sort_field key, @mods[:sort_as], dir
        end.join ', '
        "ORDER BY #{order_directives}"

      end
  
      def sort_field key, as, dir
        order_field = case key
          when "id";              "#{table_alias}.id"
          when "update";          "#{table_alias}.updated_at"
          when "create";          "#{table_alias}.created_at"
          when /^(name|alpha)$/;  "LOWER( #{table_alias}.key )"
          when 'content'
            join_alias = add_revision_join
            "lower(#{join_alias}.content)"
          when "relevance"
            if !sql.relevance_fields.empty?
              sql.fields << sql.relevance_fields
              "name_rank desc, content_rank"
            else
              "#{table_alias}.updated_at"
            end
          else
            safe_sql(key)
          end
        order_field = "CAST(#{order_field} AS #{cast_type(as)})" if as
        "#{order_field} #{dir}"
    
      end
    end
  end
end
