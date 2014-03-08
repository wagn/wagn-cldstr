class Card::SetPattern

  class << self
    attr_accessor :key, :key_id, :opt_keys, :junction_only, :method_key, :assigns_type, :anchorless
    
    def junction_only?
      !!junction_only
    end
    
    def anchorless?
      !!anchorless
    end

    def new card
      super if pattern_applies? card
    end

    def key_name
      Card.fetch(self.key_id, :skip_modules=>true).cardname
    end

    def register key, opts={}
      if self.key_id = Card::Codename[key]
        self.key = key
        Card.set_patterns.insert opts.delete(:index).to_i, self
        if self.anchorless = !respond_to?( :anchor_name )
          self.method_key = opts[:method_key] || key
        end
        self.opt_keys = Array.wrap( opts.delete(:opt_keys) || key.to_sym )
        opts.each { |key, val| send "#{key}=", val }
      else
        warn "no codename for key #{key}"
      end
    end

    def method_key_from_opts opts
      method_key || ((opt_keys.map do |opt_key|
        opts[opt_key].to_name.key.gsub('+', '-')
      end << key) * '_' )
    end

    def pattern_applies? card
      junction_only? ? card.cardname.junction? : true
    end
  end


  # Instance methods

  def initialize card
    
    unless self.class.anchorless?
      @anchor_name = self.class.anchor_name(card).to_name

      @anchor_id = if self.class.respond_to? :anchor_id
        self.class.anchor_id card
      else
        Card.fetch_id @anchor_name
      end
    end

    self
  end


  def set_module_name
    tail = case
      when self.class.anchorless?   ; self.class.key.camelize
      when opt_vals.member?( nil )  ; nil
      else "#{self.class.key.camelize}::#{opt_vals.map(&:to_s).map(&:camelize) * '::'}"
      end
    tail && "Card::Set::#{ tail }"
  end

  def set_const
    if set_module = self.set_module_name
      Card::Set.includable_modules[ set_module ]
    end

  rescue Exception => e
    warn "exception set_const #{e.inspect}, #{e.backtrace*"\n"}"
  end

  def get_method_key
    if self.class.anchorless?
      self.class.method_key
    else
      opts = {}
      self.class.opt_keys.each_with_index do |key, index|
        return nil unless opt_vals[index]
        opts[key] = opt_vals[index]
      end
      self.class.method_key_from_opts opts
    end
  end

  def opt_vals
    if @opt_vals.nil?
      @opt_vals = self.class.anchorless? ? [] : find_opt_vals
    end
    @opt_vals
  end

  def find_opt_vals
    anchor_parts = if self.class.opt_keys.size > 1
      [ @anchor_name.left, @anchor_name.right ]
    else
      [ @anchor_name ]
    end
    anchor_parts.map do |part|
      part_id = Card.fetch_id part
      part_id && Card::Codename[ part_id.to_i ] or return []
    end
  end

  def key_name
    @key_name ||= self.class.key_name
  end

  def to_s
    self.class.anchorless? ? key_name.s : "#{@anchor_name}+#{key_name}"
  end

  def inspect
    "<#{self.class} #{to_s.to_name.inspect}>"
  end

  def safe_key()
    caps_part = self.class.key.gsub(' ','_').upcase
    self.class.anchorless? ? caps_part : "#{caps_part}-#{@anchor_name.safe_key}"
  end

  def rule_set_key
    if self.class.anchorless?
      self.class.key
    elsif @anchor_id
      [ @anchor_id, self.class.key ].map( &:to_s ) * '+'
    end
  end
end
