# -*- encoding : utf-8 -*-
require 'net/http'


class GoogleMapsAddon
  def self.geocode(address)
    opts = {
      :q => address,
      :key => "ABQIAAAA5yO06x91IBr9oKK57xU-kRSWPodhC6wLLpV6xYzSog0legcbhhT0-N3OKUWSa2v_LV_VnVPbd3zgKg",
      :sensor => 'false',
      :output => 'json'
    }
    url = "http://maps.google.com/maps/geo?" + opts.map{|k,v| "#{k}=#{URI.escape(v)}" }.join('&')
    result = JSON.parse(Net::HTTP.get(URI.parse(url)))   # FIXME: error handling please
    return nil unless result["Status"]["code"] == 200    # FIMXE: log error?
    # apparently the google API likes lat,long in the opposite order for static maps.
    # since we don't have access to code when referencing the static maps address, we store them that way.
    result["Placemark"][0]["Point"]["coordinates"][0..1].reverse.join(",")
  end
end


# ##  This spec is here instead of the test suite since it actually connects to the google service
# describe GoogleMapsAddon do
#   context "geocode" do
#     it "returns correct coords for Ethan's House" do
#       GoogleMapsAddon.geocode("519 Peterson St., Ft. Collins, CO").should match(/^40.5\d+,-105.0\d+$/)
#     end
#   end
# end
