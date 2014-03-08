# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::HtmlFormat do

  describe "views" do

    it "content" do
      result = render_card(:content, :name=>'A+B')
      assert_view_select result, 'div[class="card-slot content-view card-content ALL ALL_PLUS TYPE-basic RIGHT-b TYPE_PLUS_RIGHT-basic-b SELF-a-b"]'
    end


    it "inclusions in multi edit" do
      c = Card.new :name => 'ABook', :type => 'Book'
      rendered =  Card::Format.new(c).render( :edit )

      assert_view_select rendered, 'fieldset' do
        assert_select 'textarea[name=?][class="tinymce-textarea card-content"]', 'card[cards][+illustrator][content]'
      end
    end

    it "titled" do
      result = render_card :titled, :name=>'A+B'
      assert_view_select result, 'div[class~="titled-view"]' do
        assert_select 'h1' do
          assert_select 'span'
        end
        assert_select 'div[class~="card-body card-content"]', 'AlphaBeta'
      end
    end

    context "full wrapping" do
      before do
        @ocslot = Card::Format.new(Card['A'])
      end

      it "should have the appropriate attributes on open" do
        assert_view_select @ocslot.render(:open), 'div[class="card-slot open-view card-frame ALL TYPE-basic SELF-a"]' do
          assert_select 'h1[class="card-header"]' do
            assert_select 'span[class="card-title"]'
          end
          assert_select 'div[class~="card-body"]'
        end
      end

      it "should have the appropriate attributes on closed" do
        v = @ocslot.render(:closed)
        assert_view_select v, 'div[class="card-slot closed-view card-frame ALL TYPE-basic SELF-a"]' do
          assert_select 'h1[class="card-header"]' do
            assert_select 'span[class="card-title"]'
          end
          assert_select 'div[class~="closed-content card-content"]'
        end
      end
    end

    context "Cards with special views" do

    end

    context "Simple page with Default Layout" do
      before do
        Account.as_bot do
          card = Card['A+B']
          @simple_page = Card::HtmlFormat.new(card).render(:layout)
          #warn "render sp: #{card.inspect} :: #{@simple_page}"
        end
      end


      it "renders top menu" do
        #warn "sp #{@simple_page}"
        assert_view_select @simple_page, 'div[id="menu"]' do
          assert_select 'a[class="internal-link"][href="/"]', 'Home'
          assert_select 'a[class="internal-link"][href="/recent"]', 'Recent'
          assert_select 'form.navbox-form[action="/:search"]' do
            assert_select 'input[name="_keyword"]'
          end
        end
      end

      it "renders card header" do
        # lots of duplication here...
        assert_view_select @simple_page, 'h1[class="card-header"]' do
          assert_select 'span[class="card-title"]'
        end
      end

      it "renders card content" do
        assert_view_select @simple_page, 'div[class="card-body card-content ALL ALL_PLUS TYPE-basic RIGHT-b TYPE_PLUS_RIGHT-basic-b SELF-a-b"]', 'AlphaBeta'
      end
 
      it "renders card credit" do
        assert_view_select @simple_page, 'div[class~="SELF-Xcredit"]' do#, /Wheeled by/ do
          assert_select 'img'
          assert_select 'a', "Wagn v#{Wagn::Version.release}"
        end
      end
    end

    context "layout" do
      before do
        Account.as_bot do
          @layout_card = Card.create(:name=>'tmp layout', :type=>'Layout')
          #warn "layout #{@layout_card.inspect}"
        end
        c = Card['*all+*layout'] and c.content = '[[tmp layout]]'
        @main_card = Card.fetch('Joe User')
        Wagn::Env[:main_name] = @main_card.name
        
        #warn "lay #{@layout_card.inspect}, #{@main_card.inspect}"
      end

      it "should default to core view when in layout mode" do
        @layout_card.content = "Hi {{A}}"
        Account.as_bot { @layout_card.save }

        Card::Format.new(@main_card).render(:layout).should match('Hi Alpha')
      end

      it "should default to open view for main card" do
        @layout_card.content='Open up {{_main}}'
        Account.as_bot { @layout_card.save }

        result = Card::Format.new(@main_card).render_layout
        result.should match(/Open up/)
        result.should match(/card-header/)
        result.should match(/Joe User/)
      end

      it "should render custom view of main" do
        @layout_card.content='Hey {{_main|name}}'
        Account.as_bot { @layout_card.save }

        result = Card::Format.new(@main_card).render_layout
        result.should match(/Hey.*div.*Joe User/)
        result.should_not match(/card-header/)
      end

      it "shouldn't recurse" do
        @layout_card.content="Mainly {{_main|core}}"
        Account.as_bot { @layout_card.save }

        rendered = Card::Format.new(@layout_card).render(:layout).should == 
          %{Mainly <div id="main"><div class="CodeRay">\n  <div class="code"><pre>Mainly {{_main|core}}</pre></div>\n</div>\n</div>}
          #probably better to check that it matches "Mainly" exactly twice.
      end
      
      
      it "should handle nested _main references" do
        Account.as_bot do
          @layout_card.content="{{outer space}}"
          @layout_card.save!
          Card.create :name=>"outer space", :content=>"{{_main|name}}"
        end
        
        Card::Format.new(@layout_card).render(:layout).should == 'Joe User'
      end
    end


  end

end
