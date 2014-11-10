# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::All::Rules do
  before do
    Account.current_id = Card::WagnBotID
  end

  describe "setting data setup" do
    it "should make Set of +*type" do
      Card.create! :name=>"SpeciForm", :type=>'Cardtype'
      Card.create!( :name=>"SpeciForm+*type" ).type_code.should == :set
    end
  end

  describe "#rule" do
    it "retrieves Set based value" do
      Card.create :name => "Book+*type+*add help", :content => "authorize"
      Card.new( :type => "Book" ).rule(:add_help, :fallback=>:help).should == "authorize"
    end

    it "retrieves default values" do
      #Card.create :name => "all Basic cards", :type => "Set", :content => "{\"type\": \"Basic\"}"  #defaults should work when other Sets are present
      assert c=Card.create(:name => "*all+*add help", :content => "lobotomize")
      Card.default_rule(:add_help, :fallback=>:help).should == "lobotomize"
      Card.new( :type => "Basic" ).rule(:add_help, :fallback=>:help).should == "lobotomize"
    end

    it "retrieves single values" do
      Card.create! :name => "banana+*self+*help", :content => "pebbles"
      Card["banana"].rule(:help).should == "pebbles"
    end
    
    context 'with fallback' do
      before do
        Card.create :name => "*all+*help", :content => "edit any kind of card"
      end

      it "retrieves default setting" do
        Card.new( :type => "Book" ).rule(:add_help, :fallback=>:help).should == "edit any kind of card"
      end

      it "retrieves primary setting" do
        Card.create :name => "*all+*add help", :content => "add any kind of card"
        Card.new( :type => "Book" ).rule(:add_help, :fallback=>:help).should == "add any kind of card"
      end

      it "retrieves more specific default setting" do
        Card.create :name => "*all+*add help", :content => "add any kind of card"
        Card.create :name => "*Book+*type+*help", :content => "edit a Book"
        Card.new( :type => "Book" ).rule(:add_help, :fallback=>:help).should == "add any kind of card"
      end
    end
  end


  describe "#setting_codes_by_group" do
    before do
      @pointer_key = Card::Set::Type::Setting::POINTER_KEY
      @pointer_settings =  [ :options, :options_label, :input ]
    end
    it "doesn't fail on nonexistent trunks" do
      Card.new(:name=>'foob+*right').setting_codes_by_group.class.should == Hash
    end
    
    it "returns universal setting names for non-pointer set" do
      pending "Different api, we should just put the tests in a new spec for that"
      snbg = Card.fetch('*star').setting_codes_by_group
      #warn "snbg #{snbg.class} #{snbg.inspect}"
      snbg.keys.length.should == 4
      snbg.keys.first.should be_a Symbol
      snbg.keys.member?( @pointer_key ).should_not be_true
    end

    it "returns pointer-specific setting names for pointer card (*type)" do
      pending "Different api, we should just put the tests in a new spec for that"
      # was this test wrong before?  What made Fruit a pointer without this?
      Account.as_bot do
        c1=Card.create! :name=>'Fruit+*type+*default', :type=>'Pointer'
        Card.create! :name=>'Pointer+*type'
      end
      c2 = Card.fetch('Fruit+*type')
      snbg = c2.setting_codes_by_group
      #warn "snbg #{snbg.class}, #{snbg.inspect}"
      snbg[@pointer_key].should == @pointer_settings
      c3 = Card.fetch('Pointer+*type')
      snbg = c3.setting_codes_by_group
      snbg[@pointer_key].should == @pointer_settings
    end

    it "returns pointer-specific setting names for pointer card (*self)" do
      c = Card.fetch '*star+*create+*self', :new=>{}
      snbg = c.setting_codes_by_group
      #warn "result #{snbg.inspect}"
      snbg[@pointer_key].should == @pointer_settings
    end

  end
end
