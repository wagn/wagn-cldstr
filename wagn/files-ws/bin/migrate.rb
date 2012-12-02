#!/usr/bin/env ruby

wsDir = '/usr/cldstr/wagn.org/wagn/ws'

appconfigid = ENV['APPCONFIGID']
raise "no appconfigid" unless appconfigid && !appconfigid.empty?

appconfigDir = "/var/cldstr/wagn.org/wagn/ws/#{appconfigid}"
LogFile = "/var/log/cldstr+wagn.org+wagn+ws/#{appconfigid}.log"

def get_version dir
  filename = "#{dir}/version.txt"
  if File.exists? filename
    File.read( filename ).strip
  end
end

def log msg
  File.open LogFile, 'a' do |f|
    f.puts msg
  end
end

dbversion = get_version "#{wsDir}/web/db"
appconfigVersion = get_version appconfigDir

#raise "DELETE ME" unless appconfigid == 'a0005'

if !appconfigVersion or appconfigVersion < dbversion
  Dir.chdir "#{wsDir}/web" # get us into the web directory, from which the migrate command must be run
    
  migration_command = "bundle exec env RAILS_ENV=production WAGN_CONFIG_FILE=#{appconfigDir}/wagn.yml rake db:migrate_and_stamp --trace"
  migration_results = `#{migration_command}`

  msg = "Migration Results:\n  #{migration_command}\n  #{migration_results}"
  #puts msg
  log msg 
  appconfigVersion = get_version appconfigDir
  raise msg if !appconfigVersion or appconfigVersion < dbversion
else
  log "Migration Skipped: already up to date"
end  

