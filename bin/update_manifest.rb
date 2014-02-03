#!/usr/bin/env ruby

require 'json'
require '/opt/wagn/lib/wagn/version'

MANIFEST_DIR = "#{ENV['CLDHOME']}/apps/wagn-cldstr/wagn"

manifest = File.read "#{MANIFEST_DIR}/cldstr-manifest-raw.json"
parsed = JSON.parse manifest

parsed['info']['upstreamversion'] = Wagn::Version.release

gemref = parsed['roles']['ws']['appconfigitems'].find { |x| x['target'] =~ /gems/ }
gemref['target'] = gemref['target'].gsub /wagn-[^\/]*/, "wagn-#{Wagn::Version.release}"


File.open "#{MANIFEST_DIR}/cldstr-manifest.json", 'w' do |file|
  file.write JSON.pretty_generate( parsed )
end
