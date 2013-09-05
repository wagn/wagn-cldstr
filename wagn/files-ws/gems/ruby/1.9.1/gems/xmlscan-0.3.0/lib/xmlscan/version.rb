# encoding: UTF-8
#
# xmlscan/version.rb
#
#   Copyright (C) UENO Katsuhiro 2002,2003
#
# $Id: version.rb,v 1.8.2.3 2003/05/01 15:50:00 katsu Exp $
#

module XMLScan

  GEMNAME = 'xmlscan'
  VERSION_FILE = File.expand_path('../../VERSION', File.dirname(__FILE__))
  VERSION = open(VERSION_FILE).to_a*''.chop
  RELEASE_DATE = open(VERSION_FILE).mtime.strftime('%Y-%m-%d')

end
