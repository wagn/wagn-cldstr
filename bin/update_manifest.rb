#!/usr/bin/env ruby

require 'json'

WAGN_MANIFEST="#{ENV['CLDHOME']}/apps/wagn-cldstr/wagn/cldstr-manifest.json"
VERSION_FILE="#{ENV['CLDHOME']}/apps/wagn-cldstr/wagn/files-ws/wagn-gem/card/VERSION"

file = File.read WAGN_MANIFEST
parsed = JSON.parse file

filename = '../../'
version = File.open(VERSION_FILE).read.chomp

parsed['info']['upstreamversion'] = version.gsub /\.(\d+)$/, '.r\1'
#parsed['info']['upstreamversion'] = version #FIXME -have to do this stupid r thing to get past prerelease :(

#gemref = parsed['roles']['ws']['appconfigitems'].find { |x| x['target'] =~ /gems/ }
#gemref['target'] = gemref['target'].gsub /wagn-[^\/]*/, "wagn-#{Wagn::Version.release}"

File.open "#{WAGN_MANIFEST}", 'w' do |file|
  file.write JSON.pretty_generate( parsed )
end
