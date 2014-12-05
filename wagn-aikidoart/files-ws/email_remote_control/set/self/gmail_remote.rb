def self.check_mails
  Gmail.new(Wagn.config.gmail_user,Wagn.config.gmail_password) do |gmail|


    #gmail.inbox.emails(:unread).each do |email|
    gmail.inbox.emails.each do |email|
      
      msg = email.message
      puts "found email: #{msg.subject} from #{msg.from.first}"
      
      if user = Auth[msg.from.first]
        puts "found user: #{user.name}"
        
        old_id = Card::Auth.current_id  
        Auth.current_id = user.id
        conversation = Card.fetch msg.subject, :new=>{ :type=>'Conversation' }
        conversation.save!
        
        message = Card.create!( :type=>'Message', :subcards => { 
          '+conversation' => conversation.name,
          '+message body' => msg.text_part.body.raw_source
        })
        Card::Auth.current_id = old_id
      end
      email.delete!
      
    end
  end
end