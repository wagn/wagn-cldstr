# -*- encoding : utf-8 -*-


module RenameMethods
  def name_invariant_attributes card
    {
      :content     => card.content,
      #:updater_id  => card.updater_id,
      :revisions   => card.revisions.count,
      :referencers => card.referencers.map(&:name).sort,
      :referees => card.referees.map(&:name).sort,
      :dependents  => card.dependents.map(&:id)
    }
  end

  def assert_rename card, new_name
    attrs_before = name_invariant_attributes( card )
    card.name=new_name
    card.update_referencers = true
    card.save!
    assert_equal attrs_before, name_invariant_attributes(card)
    assert_equal new_name, card.name
    assert Card[new_name]
  end

  def card name
    Card[name].refresh or raise "Couldn't find card named #{name}"
  end
end

include RenameMethods


describe Card::Set::All::TrackedAttributes do
  
  describe '#extract_subcard_args!' do
    it "should move plus keys into subcard hash" do
      raw_args = { 'name'=>'test', 'subcards'=>{ '+*oldway'=>{'content'=>'old'},  }, '+*newway'=>{'content'=>'new'} }
      subcards = Card.new.extract_subcard_args! raw_args
      raw_args['subcards'].should be_nil
      subcards.keys.sort.should == ['+*newway', '+*oldway']
    end
  end
  
  
  describe 'set_name' do


    it "should handle case variants" do
      @c = Card.create! :name=>'chump'
      @c.name.should == 'chump'
      @c.name = 'Chump'
      @c.save!
      @c.name.should == 'Chump'
    end

    it "should handle changing from plus card to simple" do
      c = Card.create! :name=>'four+five'
      c.name = 'nine'
      c.save!
      c.name.should == 'nine'
      c.left_id.should== nil
      c.right_id.should== nil
    end
    
    #FIXME - following tests more about fetch than set_name.  this spec still needs lots of cleanup

    it "test fetch with new when present" do
      Card.create!(:name=>"Carrots")
      cards_should_be_added 0 do
        c=Card.fetch "Carrots", :new=>{}
        c.save
        c.should be_instance_of(Card)
        Card.fetch("Carrots").should be_instance_of(Card)
      end
    end

    it "test_simple" do
      cards_should_be_added 1 do
        Card['Boo!'].should be_nil
        Card.create(:name=>"Boo!").should be_instance_of(Card)
        Card['Boo!'].should be_instance_of(Card)
      end
    end


    it "test fetch with new when not present" do
      cards_should_be_added 1 do
        c=Card.fetch("Tomatoes", :new=>{})
        c.save
        c.should be_instance_of(Card)
        Card.fetch("Tomatoes").should be_instance_of(Card)
      end
    end

    it "test_create_junction" do
      cards_should_be_added 3 do
        Card.create(:name=>"Peach+Pear", :content=>"juicy").should be_instance_of(Card)
      end
      Card["Peach"].should be_instance_of(Card)
      Card["Pear"].should be_instance_of(Card)
      assert_equal "juicy", Card["Peach+Pear"].content
    end

  private

    def cards_should_be_added number
      number += Card.all.count
      yield
      Card.all.count.should == number
    end

  end



  describe "renaming" do


    # FIXME: these tests are TOO SLOW!  8s against server, 12s from command line.
    # not sure if it's the card creation or the actual renaming process.
    # Card#save needs optimized in general.
    # Can't we just move this data to fixtures?


    it "renaming plus card to its own child" do
      assert_rename card("A+B"), "A+B+T"
    end

    it "clears cache for old name" do
      assert_rename Card['Menu'], 'manure'
      Card['Menu'].should be_nil
    end
  
    it "wipes old references by default" do
      c = Card['Menu']
      c.name = 'manure'
      c.save!
      Card['manure'].references_from.size.should == 0
    end
  
    it "picks up new references" do
      Card.create :name=>'kinds of poop', :content=>'[[manure]]'
      assert_rename Card['Menu'], 'manure'
      Card['manure'].references_from.size.should == 2
    end

    it "handles name variants" do
      assert_rename card("B"), "b"
    end

    it "handles plus cards renamed to simple" do
      assert_rename card("A+B"), "K"
    end
  

    it "handles flipped parts" do
      assert_rename card("A+B"), "B+A"
    end

    it "test_should_error_card_exists" do
      @t=card("T"); @t.name="A+B";
      assert !@t.save, "save should fail"
      assert @t.errors[:name], "should have errors on key"
    end

    it "test_used_as_tag" do
      @b=card("B"); @b.name='A+D'; @b.save
      assert @b.errors[:name]
    end

    it "test_update_dependents" do
      c1 =   Card["One"]
      c12 =  Card["One+Two"]
      c123 = Card["One+Two+Three"]
      c41 =  Card["Four+One"]
      c415 = Card["Four+One+Five"]

      assert_equal ["One+Two","One+Two+Three","Four+One","Four+One+Five"], [c12,c123,c41,c415].map(&:name)
      c1.name="Uno"
      c1.save!
      assert_equal ["Uno+Two","Uno+Two+Three","Four+Uno","Four+Uno+Five"], [c12,c123,c41,c415].map(&:reload).map(&:name)
    end

    it "test_should_error_invalid_name" do
      @t=card("T"); @t.name="YT_o~Yo"; @t.save
      assert @t.errors[:name]
    end

    it "test_simple_to_simple" do
      assert_rename card("A"), "Alephant"
    end

    it "test_simple_to_junction_with_create" do
      assert_rename card("T"), "C+J"
    end

    it "test_reset_key" do
      c = Card["Basic Card"]
      c.name="banana card"
      c.save!
      assert_equal 'banana_card', c.key
      assert Card["Banana Card"] != nil
    end



    it "test_rename_should_not_fail_when_updating_inaccessible_referencer" do
      Card.create! :name => "Joe Card", :content => "Whattup"
      Card::Auth.as :joe_admin do
        Card.create! :name => "Admin Card", :content => "[[Joe Card]]"
      end
      c = Card["Joe Card"]
      c.update_attributes! :name => "Card of Joe", :update_referencers => true
      assert_equal "[[Card of Joe]]", Card["Admin Card"].content
    end

    it "test_rename_should_update_structured_referencer" do
      Card::Auth.as_bot do
        c=Card.create! :name => "Pit"
        Card.create! :name => "Orange", :type=>"Fruit", :content => "[[Pit]]"
        Card.create! :name => "Fruit+*type+*structure", :content=>"this [[Pit]]"

        assert_equal "this [[Pit]]", Card["Orange"].raw_content
        c.update_attributes! :name => "Seed", :update_referencers => true
        assert_equal "this [[Seed]]", Card["Orange"].raw_content
      end
    end
    
    it 'should handle plus cards that have children' do
      Card::Auth.as_bot do
        Card.create :name=>'a+b+c+d'
        ab = Card['a+b']
        assert_rename ab, 'e+f'
      end
    end
    
    
    context "chuck" do
      before do
        Card::Auth.as_bot do
          Card.create! :name => "chuck_wagn+chuck"
        end
      end
      
      it "test_rename_name_substitution" do
        c1, c2 = Card["chuck_wagn+chuck"], Card["chuck"]
        assert_rename c2, "buck"
        assert_equal "chuck_wagn+buck", Card.find(c1.id).name
      end
      
      it "test_reference_updates_plus_to_simple" do
         c1 = Card::Auth.as_bot do
           Card.create! :name=>'Huck', :content=>"[[chuck wagn+chuck]]"
         end
         c2 = Card["chuck_wagn+chuck"]
         assert_rename c2, 'schmuck'
         c1 = Card.find(c1.id)
         assert_equal '[[schmuck]]', c1.content
      end
    end
    
    context "dairy" do
      before do
        Card::Auth.as_bot do
          Card.create! :type=>"Cardtype", :name=>"Dairy", :content => "[[/new/{{_self|name}}|new]]"
        end
      end
      
      it "test_renaming_card_with_self_link_should_not_hang" do
        c = Card["Dairy"]
        c.name = "Buttah"
        c.update_referencers = true
        c.save!
        assert_equal "[[/new/{{_self|name}}|new]]", Card["Buttah"].content
      end

      it "test_renaming_card_without_updating_references_should_not_have_errors" do
        c = Card["Dairy"]
        c.update_attributes "name"=>"Newt", "update_referencers"=>'false'
        assert_equal "[[/new/{{_self|name}}|new]]", Card["Newt"].content
      end
    end
    
    
    context "blues" do
      before do
        Card::Auth.as_bot do
          Card.create! :name => "Blue"
    
          Card.create! :name => "blue includer 1", :content => "{{Blue}}"
          Card.create! :name => "blue includer 2", :content => "{{blue|closed;other:stuff}}"
    
          Card.create! :name => "blue linker 1", :content => "[[Blue]]"
          Card.create! :name => "blue linker 2", :content => "[[blue]]"
        end
      end
      
      
      it "test_updates_inclusions_when_renaming" do
        c1,c2,c3 = Card["Blue"], Card["blue includer 1"], Card["blue includer 2"]
        c1.update_attributes :name => "Red", :update_referencers => true
        assert_equal "{{Red}}", Card.find(c2.id).content                     
        # NOTE these attrs pass through a hash stage that may not preserve order
        assert_equal "{{Red|closed;other:stuff}}", Card.find(c3.id).content
      end

      it "test_updates_inclusions_when_renaming_to_plus" do
        c1,c2 = Card["Blue"], Card["blue includer 1"]
        c1.update_attributes :name => "blue includer 1+color", :update_referencers => true
        assert_equal "{{blue includer 1+color}}", Card.find(c2.id).content                     
      end

      it "test_reference_updates_on_case_variants" do
        c1,c2,c3 = Card["Blue"], Card["blue linker 1"], Card["blue linker 2"]
        c1.reload.name = "Red"
        c1.update_referencers = true
        c1.save!
        assert_equal "[[Red]]", Card.find(c2.id).content
        assert_equal "[[Red]]", Card.find(c3.id).content
      end
    end

  end
  
end
