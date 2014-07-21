# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::All::Base do

  describe 'handles view' do
  
    it("name"    ) { render_card(:name).should      == 'Tempo Rary' }
    it("key"     ) { render_card(:key).should       == 'tempo_rary' }
    it("linkname") { render_card(:linkname).should  == 'Tempo_Rary' }

    it "url" do
      Wagn::Env[:protocol] = 'http://'
      Wagn::Env[:host]     = 'eric.skippy.com'
      render_card(:url).should == 'http://eric.skippy.com/Tempo_Rary'
    end

    it :raw do
      @a = Card.new :content=>"{{A}}"
      Card::Format.new(@a)._render(:raw).should == "{{A}}"
    end

    it "core" do
      render_card(:core, :name=>'A+B').should == "AlphaBeta"
    end
  
    describe 'array' do
      it "of search items" do
        Card.create! :name => "n+a", :type=>"Number", :content=>"10"
        Card.create! :name => "n+b", :type=>"Phrase", :content=>"say:\"what\""
        Card.create! :name => "n+c", :type=>"Number", :content=>"30"
        c = Card.new :name => 'nplusarray', :content => "{{n+*children+by create|array}}"
        Card::Format.new(c)._render( :core ).should == %{["10", "say:\\"what\\"", "30"]}
      end

      it "of pointer items" do
        Card.create! :name => "n+a", :type=>"Number", :content=>"10"
        Card.create! :name => "n+b", :type=>"Number", :content=>"20"
        Card.create! :name => "n+c", :type=>"Number", :content=>"30"
        Card.create! :name => "npoint", :type=>"Pointer", :content => "[[n+a]]\n[[n+b]]\n[[n+c]]"
        c = Card.new :name => 'npointArray', :content => "{{npoint|array}}"
        Card::Format.new(c)._render( :core ).should == %q{["10", "20", "30"]}
      end
      
      it "of basic items" do
        render_card(:array, :content=>'yoing').should==%{["yoing"]}
      end
    end
 
  end 
end

