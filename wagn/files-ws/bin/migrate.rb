#!/usr/bin/env ruby

wsDir = '/usr/cldstr/wagn.org/wagn/ws'

appconfigid = ENV['APPCONFIGID']
raise "no appconfigid" unless appconfigid && !appconfigid.empty?

appconfigDir = "/var/cldstr/wagn.org/wagn/ws/#{appconfigid}"
LogFile = "/var/log/cldstr+wagn.org+wagn+ws/#{appconfigid}.log"

def get_version dir, suffix
  filename = "#{ dir }/version#{ suffix }.txt"
  if File.exists? filename
    File.read( filename ).strip
  end
end

def log msg
  File.open LogFile, 'a' do |f|
    f.puts msg
  end
end

out_of_date = false
dbversion = {}

['', '_cards'].each do |suffix|
  dbversion[suffix] = get_version "#{ wsDir }/web/config", suffix
  appconfigVersion = get_version appconfigDir, suffix
  if !appconfigVersion or appconfigVersion < dbversion[suffix]
    out_of_date = true
    break
  end
end
#raise "DELETE ME" unless appconfigid == 'a0005'

if out_of_date
  Dir.chdir "#{wsDir}/web" # get us into the web directory, from which the migrate command must be run
    
  migration_command = "bundle exec env RAILS_ENV=production STAMP_MIGRATIONS=true WAGN_CONFIG_FILE=#{appconfigDir}/wagn.yml rake wagn:migrate --trace"
  migration_results = `#{migration_command} 2>&1`

  log "Migration Results:\n  #{migration_command}\n  #{migration_results}"

  ['', '_cards'].each do |suffix|
    appconfigVersion = get_version appconfigDir, suffix
    fail 'migration failure' if !appconfigVersion or appconfigVersion < dbversion[suffix]
  end
else
  log "Migration Skipped: already up to date"
end  

