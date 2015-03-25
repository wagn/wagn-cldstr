#!/usr/bin/env ruby

require 'json'

WAGN_MANIFEST="#{ENV['CLDHOME']}/apps/wagn-cldstr/wagn/cldstr-manifest.json"

file = File.read WAGN_MANIFEST
parsed = JSON.parse file

filename = '../wagn/files-ws/wagn-gem/card/VERSION'
version = File.open(File.expand_path( filename, __FILE__ )).read.chomp
parsed['info']['upstreamversion'] = version

#gemref = parsed['roles']['ws']['appconfigitems'].find { |x| x['target'] =~ /gems/ }
#gemref['target'] = gemref['target'].gsub /wagn-[^\/]*/, "wagn-#{Wagn::Version.release}"

File.open "#{WAGN_MANIFEST}", 'w' do |file|
  file.write JSON.pretty_generate( parsed )
end
