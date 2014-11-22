#!/usr/bin/env ruby

gemdir = '/usr/cldstr/wagn.org/wagn/ws/gems/ruby/1.9.1/gems/wagn-*'

appconfigid = ENV['APPCONFIGID']
sitename = ENV['SITENAME']
LogFile = ENV['LOGFILE']

raise "no appconfigid" unless appconfigid && !appconfigid.empty?

appconfigDir = "/var/cldstr/wagn.org/wagn/ws/#{appconfigid}"

require "#{ gemdir }/wagn/version"

def get_app_version type
  filename = "#{ appconfigDir }/version#{ Wagn::Version.schema_suffix type }.txt"
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

[:structure, :core_cards].each do |migration_type|
  dbversion[migration_type] = Wagn::Version.schema(migration_type)
  appconfigVersion = get_app_version migration_type
  if !appconfigVersion or appconfigVersion < dbversion[migration_type]
    out_of_date = true
  end
end
#raise "DELETE ME" unless appconfigid == 'a0005'


if out_of_date
#  `chown www-data.www-data #{appconfigDir}/version*` # this is needed as of wagn v1.12 to fix version.txt and version_cards.txt.  can probably remove soon
  
  Dir.chdir appconfigDir # get us into the appconfig directory, from which the migrate command must be run
  
  migration_command = "bundle exec env SCHEMA=/tmp/schema.rb SCHEMA_STAMP_PATH=./ STAMP_MIGRATIONS=true rake wagn:migrate --trace"
  begin
    migration_results = `su www-data -c "#{migration_command}" 2>&1`
  rescue
  end

  log "Migration Results:\n  #{migration_command}\n  #{migration_results}"

  [:structure, :core_cards].each do |migration_type|
    appconfigVersion = get_app_version migration_type
    if !appconfigVersion or appconfigVersion < dbversion[suffix]
      msg = "MIGRATION FAILURE: should be at #{ dbversion[suffix] }; currently at #{ appconfigVersion }"
      log msg
      abort msg 
    end
  end
else
  log "Migration Skipped: already up to date"
end
