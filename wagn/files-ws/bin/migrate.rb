#!/usr/bin/env ruby

raise "no appconfigid" unless ENV['APPCONFIGID'] && !(ENV['APPCONFIGID'].empty?)

GEMDIR = '/usr/cldstr/wagn.org/wagn/ws/wagn-gem'
DECKDIR = "/var/cldstr/wagn.org/wagn/ws/#{ ENV['APPCONFIGID'] }"
LOGFILE = ENV['LOGFILE'] || '/tmp/wagn_migration_log'

require "#{ GEMDIR }/lib/wagn/version"


def get_deck_version type
  filename = "#{ DECKDIR }/version#{ Wagn::Version.schema_suffix type }.txt"
  if filename = Dir.glob( filename ).first #completes wildcard
    File.read( filename ).strip
  end
end

def log msg
  open LOGFILE, 'a' do |f|
    f.puts msg
  end
end

out_of_date = false
gem_version = {}

[:structure, :core_cards].each do |migration_type|
  gem_version[migration_type] = Wagn::Version.schema(migration_type)
  deck_version = get_deck_version migration_type
  if !deck_version or deck_version < gem_version[migration_type]
    out_of_date = true
  end
end

if out_of_date
  
  Dir.chdir DECKDIR
  
  migration_command = "bundle exec env SCHEMA=/tmp/schema.rb SCHEMA_STAMP_PATH=./ STAMP_MIGRATIONS=true rake wagn:migrate --trace"
  begin
    migration_results = `su www-data -c "#{migration_command}" 2>&1`
  rescue => e
    log "Migration rescued: #{e.class} : #{e.message}" # is this necessary?
  end

  log "Migration Results:\n  #{migration_command}\n  #{migration_results}"

  [:structure, :core_cards].each do |migration_type|
    deck_version = get_deck_version migration_type
    if !deck_version or deck_version < gem_version[ migration_type ]
      msg = "Wagn Migration Failure: #{ ENV['APPCONFIGID'] } #{migration_type } "
      msg += "should be at #{ gem_version[migration_type] }; currently at #{ deck_version }"
      log msg
      abort msg 
    end
  end
else
  log "Migration Skipped: already up to date"
end
