# encoding: UTF-8
#
# xmlscan/visitor.rb
#
#   Copyright (C) Ueno Katsuhiro 2002
#
# $Id: visitor.rb,v 1.2 2003/01/13 04:07:25 katsu Exp $
#

require 'xmlscan/version'


module XMLScan

  class Error < StandardError

    def initialize(msg, path = nil, lineno = nil)
      super msg
      @path = path
      @lineno = lineno
    end

    attr_reader :path, :lineno

    def to_s
      if @lineno and @path then
        "#{@path}:#{@lineno}:#{super}"
      else
        super
      end
    end

  end

  class ParseError < Error ; end
  class NotWellFormedError < Error ; end
  class NotValidError < Error ; end


  module Visitor

    def parse_error(msg)
      raise ParseError.new(msg)
    end

    def wellformed_error(msg)
      raise NotWellFormedError.new(msg)
    end

    def valid_error(msg)
      raise NotValidError.new(msg)
    end

    def warning(msg)
    end

    def on_xmldecl(*a)
    end

    def on_xmldecl_key(key, str, *a)
    end

    def on_xmldecl_version(str, *a)
    end

    def on_xmldecl_encoding(str, *a)
    end

    def on_xmldecl_standalone(str, *a)
    end

    def on_xmldecl_other(name, value, *a)
    end

    def on_xmldecl_end(*a)
    end

    def on_doctype(root, pubid, sysid, *a)
    end

    def on_prolog_space(str, *a)
    end

    def on_comment(str, *a)
    end

    def on_pi(target, pi, *a)
    end

    def on_chardata(str, *a)
    end

    def on_cdata(str, *a)
    end

    def on_etag(name, *a)
    end

    def on_entityref(ref, *a)
    end

    def on_charref(code, *a)
    end

    def on_charref_hex(code, *a)
    end

    def on_start_document(*a)
    end

    def on_end_document(*a)
    end

    def on_stag(name, *a)
    end

    def on_attribute(name, *a)
    end

    def on_attr_value(str, *a)
    end

    def on_attr_entityref(ref, *a)
    end

    def on_attr_charref(code, *a)
    end

    def on_attr_charref_hex(code, *a)
    end

    def on_attribute_end(name, *a)
    end

    def on_stag_end_empty(name, *a)
    end

    def on_stag_end(name, *a)
    end

  end


  class Decoration

    include Visitor

    def initialize(visitor)
      #STDERR << "new Decoration #{visitor}\n"
      @visitor = visitor
    end

    Visitor.instance_methods.each { |i|
          #STDERR << "#{i} \#{args.inspect}\\n"
      module_eval <<-END, __FILE__, __LINE__ + 1
        def #{i}(*args)
          @visitor&&@visitor.#{i}(*args)
        end
      END
    }

  end

end
