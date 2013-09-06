# encoding: UTF-8
require 'xmlscan/parser'
require 'xmlscan/visitor'
require 'stringio'

module XMLScan
  module ElementProcessor
    include XMLScan::Visitor

    SKIP = [:on_chardata, :on_stag, :on_etag, :on_attribute, :on_attr_entityref,
      :on_attr_value, :on_start_document, :on_end_document, :on_attribute_end,
      :on_stag_end, :on_stag_end_empty, :on_attr_charref, :on_attr_charref_hex]

    MY_METHODS = XMLScan::Visitor.instance_methods.to_a - SKIP

    def initialize(opts={}, mod=nil)
      raise "No module" unless mod
      (MY_METHODS - mod.instance_methods).each do |i|
        self.class.class_eval %{def #{i}(d, *a) d&&(self << d) end}, __FILE__, __LINE__
      end
      self.class.send :include, mod

      @element = opts[:element] || raise("need an element")
      @key = opts[:key] || raise("need a key")
      @extras = (ex = opts[:extras]) ? ex.map(&:to_sym) : []
      @tmpl = opts[:substitute] || "{{:key}}"

      @pairs = {}   # output name=> [content, context, extra_values] * 1 or more
      @context = '' # current key(name) of the element (card)
      @stack = []   # stack of containing context cards
      @out = []     # current output for name(card)
      @parser = XMLScan::XMLParser.new(self)
      self
    end

  end

  class XMLProcessor
    include ElementProcessor

    def self.process(io, opts={}, mod=nil)
      mod ||= ElementProcessing
      STDERR << "process #{io.inspect}, #{opts.inspect}\n"
      io = case io
          when IO, StringIO; io
          when String; open(io)
          else raise "bad type file input #{io.inspect}"
        end

      visitor = new(opts, mod)
      visitor.parser.parse(io)
      visitor.pairs
    end
  end


  module ElementProcessing
    def <<(s) @out << s end
    def on_chardata(s) self << s end
    def on_stag_end(name, s, h, *a)
      if name.to_sym == @element
        # starting a new context, first output our substitute string
        key= h&&h[@key.to_s]||'*no-name*'
        self << @tmpl.split('|').find {
          |x| !(/:\w[\w\d]*/ =~ x) || h[$&[1..-1].to_s] }.gsub(/:\w[\w\d]*/) {
            |m| h[m[1..-1]]
         }
        # then push the current context and initialize this one
        @stack.push([@context, @out, *@ex])
        @pairs[key] = nil # insert it when first seen
        @context = key; @out = []; @ex = @extras.map {|e| h[e.to_s]}
      else self << s end # pass through tags we aren't processing
    end

    def on_etag(name, s=nil)
      if name.to_sym == @element
        # output a card (name, content, type)
        @pairs[@context] = [@out, @stack[-1][0], *@ex]
        # restore previous context from stack
        last = @stack.pop
        @context, @out, @ex = last.shift, last.shift, *last
      else self << s end
    end

    def on_stag_empty_end(name, s=nil, h={}, *a)
      if name.to_sym == @element

        key= h&&h[@key.to_s]||'*no-name*'
        ex = @extras.map {|e| h[e]}
        @pairs[key] = [[], @context, *ex]
      else self << s end
    end

    attr_reader :pairs, :parser
  end

end
