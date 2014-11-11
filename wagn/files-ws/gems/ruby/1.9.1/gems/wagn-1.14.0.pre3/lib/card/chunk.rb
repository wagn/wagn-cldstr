# -*- encoding : utf-8 -*-

require 'uri/common'

# A chunk is a pattern of text that can be protected
# and interrogated by a format. Each Chunk class has a
# +pattern+ that states what sort of text it matches.
# Chunks are initalized by passing in the result of a
# match by its pattern.

class Card
  module Chunk
    mattr_accessor :raw_list, :prefix_regexp_by_list, :prefix_map
    @@raw_list, @@prefix_regexp_by_list, @@prefix_map = {}, {}, {}
  
    class << self
      def register_class klass, hash
        klass.config = hash.merge :class => klass
        prefix_index = hash[:idx_char] || :default  # this is gross and needs to be moved out.  
        prefix_map[prefix_index] = klass.config
      end
    
      def register_list key, list
        raw_list[key] = list
      end
    
      def find_class_by_prefix prefix
        config = prefix_map[ prefix[0,1] ] || prefix_map[ prefix[-1,1] ] || prefix_map[:default]
        #prefix identified by first character, last character, or default.  a little ugly...
        config[:class]
      end
    
      def get_prefix_regexp chunk_list_key
        prefix_regexp_by_list[chunk_list_key] ||= begin
          chunk_types = raw_list[chunk_list_key].map { |chunkname| const_get chunkname }
          prefix_res = chunk_types.map do |chunk_class|
            chunk_class.config[:prefix_re]
          end
          /(?:#{ prefix_res * '|' })/m
        end
      end

    end
  
  
    #not sure whether this is best place.  Could really happen almost anywhere (even before chunk classes are loaded).
    register_list :default, [ :URI, :HostURI, :EmailURI, :EscapedLiteral, :Include, :Link ]
    register_list :references,                         [ :EscapedLiteral, :Include, :Link ]
    register_list :inclusion_only,                     [  :Include ]
    register_list :inclusion_and_link,                 [  :Include, :Link ]
  
    class Abstract
      class_attribute :config
      attr_reader :text, :process_chunk
    
      class << self
        def full_match content, prefix=nil
  #        warn "attempting full match on #{content}.  class = #{self}"
          content.match full_re( prefix )
        end

        def full_re prefix
          config[:full_re]
        end
      
        def context_ok? content, chunk_start
          true
        end
      end

      def initialize match, content
        @text = match[0]
        @processed = nil
        @content = content
        interpret match, content
        self
      end
    
      def interpret match_string, content, params
        Rails.logger.info "no #interpret method found for chunk class: #{self.class}"
      end
    
      def format
        @content.format
      end
    
      def card
        @content.card
      end

      def to_s
        @process_chunk || @processed || @text
      end

      def inspect
        "<##{self.class}##{to_s}>"
      end

      def as_json(options={})
        @process_chunk || @processed|| "not rendered #{self.class}, #{card and card.name}"
      end
    end
  end
  Loader.load_chunks
end
