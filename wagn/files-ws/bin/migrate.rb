#!/usr/bin/env ruby

gemdir = '/usr/cldstr/wagn.org/wagn/ws/gems/ruby/1.9.1/gems/wagn-*'

appconfigid = ENV['APPCONFIGID']
sitename = ENV['SITENAME']
raise "no appconfigid" unless appconfigid && !appconfigid.empty?

appconfigDir = "/var/cldstr/wagn.org/wagn/ws/#{appconfigid}"
LogFile = "/var/log/cldstr+wagn.org+wagn+ws/#{appconfigid}.log"

def get_version dir, suffix
  filename = "#{ dir }/version#{ suffix }.txt"
  if filename = Dir.glob( filename ).first #completes wildcard
    File.read( filename ).strip
  end
end

def log msg
  open LogFile, 'a' do |f|
    f.puts msg
  end
end

out_of_date = false
dbversion = {}

['', '_cards'].each do |suffix|
  dbversion[suffix] = get_version "#{ gemdir }/config", suffix
  appconfigVersion = get_version appconfigDir, suffix
  if !appconfigVersion or appconfigVersion < dbversion[suffix]
    out_of_date = true
  end
end
#raise "DELETE ME" unless appconfigid == 'a0005'


if out_of_date
  `chown www-data.www-data #{appconfigDir}/version*` # this is needed as of wagn v1.12 to fix version.txt and version_cards.txt.  can probably remove soon
  
  Dir.chdir appconfigDir # get us into the appconfig directory, from which the migrate command must be run
  
  migration_command = "bundle exec env STAMP_MIGRATIONS=true rake wagn:migrate --trace"
  migration_results = `su www-data -c "#{migration_command}" 2> #{LogFile}`

  log "Migration Results:\n  #{migration_command}\n  #{migration_results}"

  ['', '_cards'].each do |suffix|
    appconfigVersion = get_version appconfigDir, suffix
    puts 'migration failure' if !appconfigVersion or appconfigVersion < dbversion[suffix]
  end
else
  log "Migration Skipped: already up to date"
end
