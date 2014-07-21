# What is this?
# The Machine module together with the MachineInput module implements a kind of observer pattern.  
# It handles a collection of input cards to generate a output card (default is a file card). 
# If one of the input cards is changed the output card will be updated.
# The classic example: 
# A style card observes a collection of css and sccs card to generate a file card with a css file containg the assembled compressed css.

# How to use it?
# Include the Machine module in the card set that is supposed to produce the output card. If the output card should be autmatically updated when a input card is changed the input card has to be in a set that includes the MachineInput module.
# The default machine
#  -  uses its item cards as input cards or the card itself if there are no item cards;
#     can be changed by passing a block to collect_input_cards 
#  -  takes the raw view of the input cards to generate the output;
#     can be changed by passing a block to machine_input (in the input card set)
#  -  stores the output as a .txt file in the "+machine output" card;
#     can be cahnged by passing a filetype and/or a block to store_machine_output


# How does it work?
# Machine cards have a +machine input and a +machine output card. The +machine input card is a pointer to all input cards.
# Including the MachineInput module creates an ":on => save" event that runs the machines of all cards that are linked to that card via the +machine input pointer. 



class Card
  module Machine    
    module ClassMethods
      attr_accessor :output_config 
  
      def collect_input_cards &block
        define_method :engine_input, &block
      end
      
      def prepare_machine_input &block
        define_method :before_engine, &block
      end
  
      def machine_engine &block
        define_method :engine, &block
      end
  
      def store_machine_output args={}, &block
        output_config.merge!(args)
        if block_given?
          define_method :after_engine, &block
        end
      end
    end

    def self.included(host_class)
      host_class.extend( ClassMethods )
      host_class.output_config = { :filetype => "txt" }
      
            
      if Codename[:machine_output]  # for compatibility with old migrations
        host_class.card_accessor :machine_output, :type=>:file
        host_class.card_accessor :machine_input, :type => :pointer
  
        # define default machine behaviour
        host_class.collect_input_cards do 
          # traverse through all levels of pointers and
          # collect all item cards as input 
          items = [self]
          new_input = []
          already_extended = {} # avoid loops
          loop_limit = 5
          while items.size > 0
            item = items.shift
            if item.trash or ( already_extended[item.id] and already_extended[item.id] > loop_limit)
              next
            elsif item.item_cards == [item]  # no pointer card
              new_input << item
            else
              items.insert(0, item.item_cards)
              items.flatten!
              new_input << item if item != self
              already_extended[item] = already_extended[item] ? already_extended[item] + 1 : 1
            end
          end
          new_input
        end

        host_class.prepare_machine_input {}
        host_class.machine_engine { |input| input }
        host_class.store_machine_output do |output| 
          file = Tempfile.new [ id, ".#{host_class.output_config[:filetype]}" ]
          file.write output
          Card::Auth.as_bot do
            p = machine_output_card
            p.attach = file
            p.save!
          end
          file.close
          file.unlink
        end
  
        host_class.format do
          view :machine_output_url do |args|
            machine_output_url
          end
        end
  
        host_class.event "update_machine_output_#{host_class.name.gsub(':','_')}".to_sym, :after => :store_subcards, :on => :save do  
          update_machine_output
        end
      end
    end

    def run_machine joint="\n"
      before_engine
      output = input_item_cards.map do |input|
        unless input.kind_of? Card::Set::Type::Pointer
          if input.respond_to? :machine_input
            engine( input.machine_input ) 
          else
            engine( input.format._render_raw )
          end
        end
      end.select(&:present?).join( joint )
      after_engine output
    end
 
    def update_machine_output updated=[]
      update_input_card
      run_machine
    end

    def update_input_card
      Card::Auth.as_bot do
        machine_input_card.items = engine_input
        #machine_input_card.save
      end
    end

    def input_item_cards
      machine_input_card.item_cards
    end

    def machine_output_url
      ensure_machine_output
      machine_output_card.attach.url #(:default, :timestamp => false)   # to get rid of additional number in url
    end 

    def machine_output_path
      ensure_machine_output
      machine_output_card.attach.path
    end 

    def ensure_machine_output
      unless fetch :trait => :machine_output
        update_machine_output 
      end
    end
  end
end

