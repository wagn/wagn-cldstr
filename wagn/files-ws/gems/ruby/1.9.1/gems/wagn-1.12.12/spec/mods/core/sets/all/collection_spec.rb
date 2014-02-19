# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::All::Collection do
  describe "#item_names" do
    it "returns item for each line of basic content" do
      Card.new( :name=>"foo", :content => "X\nY" ).item_names.should == ["X","Y"]
    end

    it "returns list of card names for search" do
      c = Card.new( :name=>"foo", :type=>"Search", :content => %[{"name":"Z"}])
      c.item_names.should == ["Z"]
    end

    it "handles searches relative to context card" do
      # note: A refers to 'Z'
      Card.new(:name=>"foo", :type=>"Search", :content => %[{"referred_to_by":"_self"}]).item_names( :context=>'A' ).should == ["Z"]
    end
  end

  describe "#extended_list" do
    it "returns item's content for pointer setting" do
      c = Card.new(:name=>"foo", :type=>"Pointer", :content => "[[Z]]")
      c.extended_list.should == ["I'm here to be referenced to"]
    end
  end

  describe "#contextual_content" do
    it "returns content for basic setting" do
      Card.new(:name=>"foo", :content => "X").contextual_content.should == "X"
    end

    it "processes inclusions relative to context card" do
      context_card = Card["A"] # refers to 'Z'
      c = Card.new(:name=>"foo", :content => "{{_self+B|core}}")
      c.contextual_content( context_card ).should == "AlphaBeta"
    end

    it "returns content even when context card is hard templated" do #why the heck is this good?  -efm
      context_card = Card["A"] # refers to 'Z'
      
      Account.as_bot do
        Card.create! :name => "A+*self+*structure", :content => "Banana"
      end
      c = Card.new( :name => "foo", :content => "{{_self+B|core}}" )
      c.contextual_content( context_card ).should == "AlphaBeta"
    end
  end
end
