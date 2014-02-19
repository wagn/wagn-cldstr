#!/usr/bin/env ruby

require 'json'
require '/opt/wagn/lib/wagn/version'

WAGN_MANIFEST="#{ENV['CLDHOME']}/apps/wagn-cldstr/wagn/cldstr-manifest.json"

file = File.read WAGN_MANIFEST
parsed = JSON.parse file

parsed['info']['upstreamversion'] = Wagn::Version.release

gemref = parsed['roles']['ws']['appconfigitems'].find { |x| x['target'] =~ /gems/ }
gemref['target'] = gemref['target'].gsub /wagn-[^\/]*/, "wagn-#{Wagn::Version.release}"

File.open "#{WAGN_MANIFEST}", 'w' do |file|
  file.write JSON.pretty_generate( parsed )
end
