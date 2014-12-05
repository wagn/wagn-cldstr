Wagn.config.gmail_user = 'wagnculture@gmail.com'
Wagn.config.gmail_password = 'br8nd0nwc'
Wagn.config.gmail_interval = '30s'

if Wagn.config.gmail_user
    
  require 'rufus-scheduler'

  scheduler = Rufus::Scheduler.new

  scheduler.every Wagn.config.gmail_interval do
    Card::Set::Self::GmailRemote.check_mails
  end
  
end
#scheduler.join