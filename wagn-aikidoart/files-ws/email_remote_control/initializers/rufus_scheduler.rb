
filename = "#{Wagn.root}/remote_email_config.yml"
WAGN_REMOTE_EMAIL_CONFIG = File.exist?(filename) ? YAML.load_file(filename) : {}


if WAGN_REMOTE_EMAIL_CONFIG[:gmail_user]
    
  require 'rufus-scheduler'

  scheduler = Rufus::Scheduler.new

  scheduler.every WAGN_REMOTE_EMAIL_CONFIG[:gmail_interval] do
    Card::Set::Self::GmailRemote.check_mails
  end
  
end

