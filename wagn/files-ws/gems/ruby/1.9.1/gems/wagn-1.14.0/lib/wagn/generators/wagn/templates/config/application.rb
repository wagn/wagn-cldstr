require File.expand_path('../boot', __FILE__)

require 'wagn/all'

module <%= app_const_base %>
  class Application < Wagn::Application
    
    # Wagn inherits Rails configuration options.  See http://guides.rubyonrails.org/configuring.html

    config.recaptcha_public_key  = '6LdhRssSAAAAAFfLt1Wkw43hoaA8RTIgso9-tvtc'
    config.recaptcha_private_key = '6LdhRssSAAAAAGwzl069pJQBdmzCZigm1nV-dmqK'
    # config.recaptcha_proxy = ...
    #
    # IMPORTANT: please be sure to register for your own recaptcha keys before deploying a live site
    # It's quick and easy.  Just follow instructions at https://www.google.com/recaptcha/admin/create
  
    
    # Email configuration
    config.action_mailer.perform_deliveries = false
    # config.action_mailer.delivery_method  = ...
    # config.action_mailer.smtp_settings    = ...
    
    # Example configuration for mailcatcher, a simple smtp server. 
    # See http://mailcatcher.me for more information
    # config.action_mailer.delivery_method = :smtp
    # config.action_mailer.smtp_settings = { :address => "localhost", :port => 1025 }
    
    # The below keys are fine for testing but should not be used in production sites.
        
    # config.read_only = true
    # defaults to false
    # disallows creating, updating, and deleting cards.

    # config.cache_store = :file_store, 'tmp/cache'
    # determines caching mechanism.  options include: file_store, memory_store, mem_cache_store, dalli_store...
    #
    # for production, we highly recommend memcache
    # here's a sample configuration for use with the dalli gem
    # config.cache_store = :dalli_store, []

    # config.paths['files'] = 'files'
    # where uploaded files are actually stored. (eg Image and File cards)

    # config.paths['local-mod'] = 'mod'
    # where mods are stored

    # config.allow_inline_styles = false
    # don't strip style attributes (not recommended)
        
    # config.override_host = nil
    # don't autodetect host (example.com) from web requests

    # config.override_protocol = nil
    # don't autodetect protocol (http/https) from web requests
  end
end
