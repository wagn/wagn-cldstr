# -*- encoding : utf-8 -*-
require 'spork'
ENV["RAILS_ENV"] = 'test'


require File.expand_path( '../../lib/wagn/simplecov_helper.rb', __FILE__ )
require 'simplecov'
require 'timecop'
require File.expand_path( '../../mod/03_machines/spec/lib/machine_spec.rb', __FILE__ )
require File.expand_path( '../../mod/03_machines/spec/lib/machine_input_spec.rb', __FILE__ )



Spork.prefork do
  if ENV["RAILS_ROOT"]
    require File.join( ENV["RAILS_ROOT"], '/config/environment')
  else
    require File.expand_path( '../../config/environment', __FILE__ )
  end
  
  require 'rspec/rails'
  require File.expand_path( '../../lib/wagn/spec_helper.rb', __FILE__ )
  
  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
#  Dir[ File.join(Wagn.gem_root, "spec/support/**/*.rb") ].each { |f| require f }

#  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  JOE_USER_ID = Card['joe_user'].id
  RSpec.configure do |config|

    config.include RSpec::Rails::Matchers::RoutingMatchers,  {
      :file_path => /\bspec\/controllers\//
    }

    # format_index = ARGV.find_index {|arg| arg =~ /--format|-f/ }
    # formatter = format_index ? ARGV[ format_index + 1 ] : 'documentation' #'textmate'
    # config.default_formatter=formatter
    
    config.infer_spec_type_from_file_location!
    #config.include CustomMatchers
    #config.include ControllerMacros, :type=>:controllers

    # == Mock Framework
    # If you prefer to mock with mocha, flexmock or RR, uncomment the appropriate symbol:
    # :mocha, :flexmock, :rr
    #require 'wagn-rspec-formatter'
    config.mock_with :rr

    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false
    
    config.mock_with :rspec do |mocks|
       mocks.syntax = [:should, :expect]
       mocks.verify_partial_doubles = true
     end
    config.expect_with :rspec do |c|
      c.syntax = [:should, :expect]
    end
    config.before(:each) do
      Card::Auth.current_id = JOE_USER_ID
      Wagn::Cache.restore
      Card::Env.reset
    end
    config.after(:each) do
      Timecop.return
    end
  end
end

Card['*all+*style' ].ensure_machine_output
Card['*all+*script'].ensure_machine_output


Spork.each_run do

  # This code will be run each time you run your specs.
end


class Card
  def self.create_or_update! name, args={}
    Card::Auth.as_bot do
      if c = Card.fetch(name)
        c.update_attributes!(args)
      else
        Card.create! args.merge({:name=>name})
      end
    end
  end
  
  def self.gimme! name, args = {}
    Card::Auth.as_bot do
      c = Card.fetch( name, :new => args )
      c.putty args
      Card.fetch name 
    end    
  end
  
  def self.gimme name, args = {}
    Card::Auth.as_bot do
      c = Card.fetch( name, :new => args )
      if args[:content] and c.content != args[:content]
        c.putty args
        c = Card.fetch name 
      end
      c
    end    
  end
  
  def putty args = {}
    Card::Auth.as_bot do
      if args.present? 
        update_attributes! (args) 
      else 
        save!
      end
    end
  end
end

RSpec::Core::ExampleGroup.send :include, Wagn::SpecHelper

class ActiveSupport::BufferedLogger
  def rspec msg
    Thread.current['logger-output'] << msg
  end
end

