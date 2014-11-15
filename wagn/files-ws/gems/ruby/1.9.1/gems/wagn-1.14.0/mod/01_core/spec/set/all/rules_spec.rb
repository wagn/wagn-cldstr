# -*- encoding : utf-8 -*-

describe Card::Set::All::Rules do
  before do
    Card::Auth.current_id = Card::WagnBotID
  end

  describe "setting data setup" do
    it "should make Set of +*type" do
      Card.create! :name=>"SpeciForm", :type=>'Cardtype'
      expect(Card.create!( :name=>"SpeciForm+*type" ).type_code).to eq(:set)
    end
  end

  describe "#rule" do
    it "retrieves Set based value" do
      Card.create :name => "Book+*type+*add help", :content => "authorize"
      expect(Card.new( :type => "Book" ).rule(:add_help, :fallback=>:help)).to eq("authorize")
    end

    it "retrieves default values" do
      #Card.create :name => "all Basic cards", :type => "Set", :content => "{\"type\": \"Basic\"}"  #defaults should work when other Sets are present
      assert c=Card.create(:name => "*all+*add help", :content => "lobotomize")
#      Card.default_rule(:add_help, :fallback=>:help).should == "lobotomize"
      expect(Card.new( :type => "Basic" ).rule(:add_help, :fallback=>:help)).to eq("lobotomize")
    end

    it "retrieves single values" do
      Card.create! :name => "banana+*self+*help", :content => "pebbles"
      expect(Card["banana"].rule(:help)).to eq("pebbles")
    end
    
    context 'with fallback' do
      before do
        Card.create :name => "*all+*help", :content => "edit any kind of card"
      end

      it "retrieves default setting" do
        expect(Card.new( :type => "Book" ).rule(:add_help, :fallback=>:help)).to eq("edit any kind of card")
      end

      it "retrieves primary setting" do
        Card.create :name => "*all+*add help", :content => "add any kind of card"
        expect(Card.new( :type => "Book" ).rule(:add_help, :fallback=>:help)).to eq("add any kind of card")
      end

      it "retrieves more specific default setting" do
        Card.create :name => "*all+*add help", :content => "add any kind of card"
        Card.create :name => "*Book+*type+*help", :content => "edit a Book"
        expect(Card.new( :type => "Book" ).rule(:add_help, :fallback=>:help)).to eq("add any kind of card")
      end
    end
  end


  describe "#setting_codenames_by_group" do
    before do
      @pointer_settings =  [ :options, :options_label, :input ]
    end
    it "doesn't fail on nonexistent trunks" do
      expect(Card.new(:name=>'foob+*right').setting_codenames_by_group.class).to eq(Hash)
    end
    
    it "returns universal setting names for non-pointer set" do
      skip "Different api, we should just put the tests in a new spec for that"
      snbg = Card.fetch('*star').setting_codenames_by_group
      #warn "snbg #{snbg.class} #{snbg.inspect}"
      expect(snbg.keys.length).to eq(4)
      expect(snbg.keys.first).to be_a Symbol
      expect(snbg.keys.member?( :pointer )).not_to be_truthy
    end


    it "returns pointer-specific setting names for pointer card" do
      c = Card.fetch 'Fruit+*type+*create+*self', :new=>{}
      snbg = c.setting_codenames_by_group
      expect(snbg[:pointer]).to eq(@pointer_settings)
    end

  end
end
