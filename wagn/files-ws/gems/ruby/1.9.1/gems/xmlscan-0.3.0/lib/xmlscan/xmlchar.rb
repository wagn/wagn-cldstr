# encoding: UTF-8
#
# xmlscan/scanner.rb
#
#   Copyright (C) Ueno Katsuhiro 2002
#
# $Id: xmlchar.rb,v 1.5.2.2 2003/05/01 14:25:55 katsu Exp $
#

require 'xmlscan/scanner'


module XMLScan

  ENC_UTF8 = Encoding.find('UTF-8')

  module XMLChar

    CharPattern = /\\A[\P{C}\t\n\r]*\\z/u
    NotCharPattern = /[^\P{C}\t\n\r]/u

    NmtokenPattern = /\\A[\p{Alnum}]+\z/u
    NotNameCharPattern = /[^\p{Alnum}}]/u

    NamePattern = /\A[\:\_\p{Letter}][\:\_\-\.\p{Alnum}]*\z/u

    def valid_char?(code)
      return false if code > 0x10ffff
      NotCharPattern !~ [code].pack('U')
    end

    def valid_chardata?(str)
      NotCharPattern !~ str
    end

    def valid_nmtoken?(str)
      NotNameCharPattern !~ str
    end

    def valid_name?(str)
      not NamePattern !~ str
    end

    module_function :valid_char?, :valid_chardata?
    module_function :valid_nmtoken?, :valid_name?


    def valid_pubid?(str)
      /[^\- \r\na-zA-Z0-9'()+,.\/:=?;!*#\@$_%]/u !~ str
    end


    def valid_version?(str)
      /[^\-a-zA-Z0-9_.:]/u !~ str
    end
    module_function :valid_version?


    def valid_encoding?(str)
      if /\A[A-Za-z]([\-A-Za-z0-9._])*\z/u =~ str then
        true
      else
        false
      end
    end
    module_function :valid_encoding?

  end




  class XMLScanner

    module StrictChar

      include XMLChar

      private

      def check_valid_name(name)
        unless valid_name? name then
          parse_error "`#{name}' is not valid for XML name"
        end
      end

      def check_valid_chardata(str)
        unless valid_chardata? str then
          parse_error "invlalid XML character is found"
        end
      end

      def check_valid_char(code)
        unless valid_char? code then
          wellformed_error "#{code} is not a valid XML character"
        end
      end

      def check_valid_version(str)
        unless valid_version? str then
          parse_error "#{str} is not a valid XML version"
        end
      end

      def check_valid_encoding(str)
        unless valid_encoding? str then
          parse_error "#{str} is not a valid XML encoding name"
        end
      end

      def check_valid_pubid(str)
        unless valid_pubid? str then
          parse_error "#{str} is not a valid public ID"
        end
      end


      def on_xmldecl_version(str, *a)
        check_valid_version str
        super
      end

      def on_xmldecl_encoding(str, *a)
        check_valid_encoding str
        super
      end

      def on_xmldecl_standalone(str, *a)
        check_valid_chardata str
        super
      end

      def on_doctype(root, pubid, sysid, *a)
        check_valid_name root
        check_valid_pubid pubid if pubid
        check_valid_chardata sysid if sysid
        super
      end

      def on_comment(str, *a)
        check_valid_chardata str
        super
      end

      def on_pi(target, pi, *a)
        check_valid_name target
        check_valid_chardata pi
        super
      end

      def on_chardata(str, *a)
        check_valid_chardata str
        super
      end

      def on_cdata(str, *a)
        check_valid_chardata str
        super
      end

      def on_etag(name, *a)
        check_valid_name name
        super
      end

      def on_entityref(ref, *a)
        check_valid_name ref
        super
      end

      def on_charref(code, *a)
        check_valid_char code
        super
      end

      def on_charref_hex(code, *a)
        check_valid_char code
        super
      end

      def on_stag(name, *a)
        check_valid_name name
        super
      end

      def on_attribute(name, *a)
        check_valid_name name
        super
      end

      def on_attr_value(str, *a)
        check_valid_chardata str
        super
      end

      def on_attr_entityref(ref, *a)
        check_valid_name ref
        super
      end

      def on_attr_charref(code, *a)
        check_valid_char code
        super
      end

      def on_attr_charref_hex(code, *a)
        check_valid_char code
        super
      end

    end


    private

    def apply_option_strict_char
      extend StrictChar
    end

  end


end






if $0 == __FILE__ then
  class TestVisitor
    include XMLScan::Visitor
    def parse_error(msg)
      STDERR.printf("%s:%d: %s\n", $s.path, $s.lineno, msg) if $VERBOSE
    end
    def wellformed_error(msg)
      STDERR.printf("%s:%d: WFC: %s\n", $s.path, $s.lineno, msg) if $VERBOSE
    end
  end

  $s = scan = XMLScan::XMLScanner.new(TestVisitor.new, :strict_char)
  src = ARGF
  def src.path; filename; end
  t1 = Time.times.utime
  scan.parse src
  t2 = Time.times.utime
  STDERR.printf "%2.3f sec\n", t2 - t1
end
