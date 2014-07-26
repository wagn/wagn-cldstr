# -*- encoding : utf-8 -*-

describe CardController do

  include Wagn::Location

  describe "- route generation" do

    it "should recognize type" do
      { :get => "/new/Phrase" }.should route_to( :controller => 'card', :action=>'read', :type=>'Phrase', :view=>'new' )
    end

    it "should recognize .rss on /recent" do
      {:get => "/recent.rss"}.should route_to(:controller=>"card", :action=>"read", :id=>":recent", :format=>"rss")
    end

    it "should handle RESTful posts" do
      { :put => '/mycard' }.should route_to( :controller=>'card', :action=>'update', :id=>'mycard')
      { :put => '/' }.should route_to( :controller=>'card', :action=>'update')
      
    end

    it "handle asset requests" do
       { :get => "/asset/application.js" }.should route_to( :controller => 'card',:action=>'asset', :id => 'application', :format=> 'js' )
    end

    ["/wagn",""].each do |prefix|
      describe "routes prefixed with '#{prefix}'" do
        it "should recognize .rss format" do
          {:get => "#{prefix}/*recent.rss"}.should route_to(
            :controller=>"card", :action=>"read", :id=>"*recent", :format=>"rss"
          )
        end

        it "should recognize .xml format" do
          {:get => "#{prefix}/*recent.xml"}.should route_to(
            :controller=>"card", :action=>"read", :id=>"*recent", :format=>"xml"
          )
        end

        it "should accept cards without dots" do
          {:get => "#{prefix}/random"}.should route_to(
            :controller=>"card",:action=>"read",:id=>"random"
          )
        end
        
      end
    end
  end

  describe "#create" do
    before do
      login_as 'joe_user'
    end

    # FIXME: several of these tests go all the way to DB,
    #  which means they're closer to integration than unit tests.
    #  maybe think about refactoring to use mocks etc. to reduce
    #  test dependencies.
    it "creates cards" do
      post :create, :card => {
        :name=>"NewCardFoo",
        :type=>"Basic",
        :content=>"Bananas"
      }
      assert_response 302
      c=Card["NewCardFoo"]
      c.type_code.should == :basic
      c.content.should == "Bananas"
    end

    it "handles permission denials" do
      post :create, :card => {
        :name => 'LackPerms',
        :type => 'Html'
      }
      assert_response 403
      Card['LackPerms'].should be_nil
    end

    # no controller-specific handling.  move test elsewhere
    it "creates cardtype cards" do
      xhr :post, :create, :card=>{"content"=>"test", :type=>'Cardtype', :name=>"Editor"}
      assigns['card'].should_not be_nil
      assert_response 200
      c=Card["Editor"]
      c.type_code.should == :cardtype
    end

    # no controller-specific handling.  move test elsewhere
    it "pulls deleted cards from trash" do
      @c = Card.create! :name=>"Problem", :content=>"boof"
      @c.delete!
      post :create, :card=>{"name"=>"Problem","type"=>"Phrase","content"=>"noof"}
      assert_response 302
      c=Card["Problem"]
      c.type_code.should == :phrase
    end

    

    context "multi-create" do
      it "catches missing name error" do
        post :create, "card"=>{
            "name"=>"",
            "type"=>"Fruit",
            "subcards"=>{"+text"=>{"content"=>"<p>abraid</p>"}}
          }, "view"=>"open"
        assert_response 422
        assigns['card'].errors[:name].first.should == "can't be blank"
      end

      it "creates card with subcards" do
        login_as 'joe_admin'
        xhr :post, :create, :success=>'REDIRECT: /', :card=>{
          :name  => "Gala",
          :type  => "Fruit",
          :subcards => {
            "+kind"  => { :content => "apple"} ,
            "+color" => { :type=>'Phrase', :content => "red"  }
          }
        }
        assert_response 200
        Card["Gala"].should_not be_nil
        Card["Gala+kind"].content.should == 'apple'
        Card["Gala+color"].type_name.should == 'Phrase'
      end
    end

    it "renders errors if create fails" do
      post :create, "card"=>{"name"=>"Joe User"}
      assert_response 422
    end

    it "redirects to thanks if present" do
      login_as 'joe_admin'
      xhr :post, :create, :success => 'REDIRECT: /thank_you', :card => { "name" => "Wombly" }
      assert_response 200
      json = JSON.parse response.body
      json['redirect'].should =~ /^http.*\/thank_you$/
    end

    it "redirects to card if thanks is blank" do
      login_as 'joe_admin'
      post :create, :success => 'REDIRECT: _self', "card" => { "name" => "Joe+boop" }
      assert_redirected_to "/Joe+boop"
    end

    it "redirects to previous" do
      # Fruits (from shared_data) are anon creatable but not readable
      login_as :anonymous
      post :create, { :success=>'REDIRECT: *previous', "card" => { "type"=>"Fruit", :name=>"papaya" } }, :history=>['/blam']
      assert_redirected_to "/blam"
    end
  end

  describe "#read" do
    it "works for basic request" do
      get :read, {:id=>'Sample_Basic'}
      response.body.match(/\<body[^>]*\>/im).should be_true
      # have_selector broke in commit 8d3bf2380eb8197410e962304c5e640fced684b9, presumably because of a gem (like capybara?)
      #response.should have_selector('body')
      assert_response :success
      'Sample Basic'.should == assigns['card'].name
    end


    it "handles nonexistent card with create permission" do
      login_as 'joe_user'
      get :read, {:id=>'Sample_Fako'}
      assert_response :success
    end

    it "handles nonexistent card without create permissions" do
      get :read, {:id=>'Sample_Fako'}
      assert_response 404
    end
    
    it "handles nonexistent card ids" do
      get :read, {:id=>'~9999999'}
      assert_response 404
    end

    it "returns denial when no read permission" do
      Card::Auth.as_bot do
        Card.create! :name=>'Strawberry', :type=>'Fruit' #only admin can read
      end
      get :read, :id=>'Strawberry'
      assert_response 403
      get :read, :id=>'Strawberry', :format=>'txt'
      assert_response 403
      
    end
    
    context "view = new" do
      before do
        login_as 'joe_user'
      end

      it "should work on index" do
        get :read, :view=>'new'
        assigns['card'].name.should == ''
        assert_response :success, "response should succeed"
        assert_equal Card::BasicID, assigns['card'].type_id, "@card type should == Basic"
      end

      it "new with name" do
        post :read, :card=>{:name=>"BananaBread"}, :view=>'new'
        assert_response :success, "response should succeed"
        assert_equal 'BananaBread', assigns['card'].name, "@card.name should == BananaBread"
      end

      it "new with existing name" do
        get :read, :card=>{:name=>"A"}, :view=>'new'
        assert_response :success, "response should succeed"  #really?? how come this is ok?
      end
      
      it "new with type_code" do
        post :read, :card => {:type=>'Date'}, :view=>'new'
        assert_response :success, "response should succeed"
        assert_equal Card::DateID, assigns['card'].type_id, "@card type should == Date"
      end
      
      it "new should work for creatable nonviewable cardtype" do
        login_as :anonymous
        get :read, :type=>"Fruit", :view=>'new'
        assert_response :success
      end
      
      it "should use card params name over id in new cards" do
        get :read, :id=>'my_life', :card=>{:name =>'My LIFE'}, :view=>'new'
        assigns['card'].name.should == 'My LIFE'
      end
      
    end
    
    
    
    context 'css' do
      before do
        @all_style = Card[ "#{ Card[:all].name }+#{ Card[:style].name }" ]
        @all_style.reset_machine_output!
      end
      
      it 'should create missing machine output file' do
        args = { :id=>@all_style.machine_output_card.name, :format=>'css', :explicit_file=>true }
        get :read, args
        output_card = Card[ "#{ Card[:all].name }+#{ Card[:style].name }+#{ Card[:machine_output].name}" ]
        expect(response).to redirect_to( @all_style.machine_output_url )
        get :read, args
        expect(response.status).to eq(200)
      end
    end
    
  
    context "file" do
      before do
        Card::Auth.as_bot do
          Card.create :name => "mao2", :type_code=>'image', :attach=>File.new("#{Wagn.gem_root}/test/fixtures/mao2.jpg")
          Card.create :name => 'mao2+*self+*read', :content=>'[[Administrator]]'
        end
      end
    
      it "handles image with no read permission" do
        get :read, :id=>'mao2'
        assert_response 403, "should deny html card view"
        get :read, :id=>'mao2', :format=>'jpg'
        assert_response 403, "should deny simple file view"
      end
    
      it "handles image with read permission" do
        login_as :joe_admin
        get :read, :id=>'mao2'
        assert_response 200
        get :read, :id=>'mao2', :format=>'jpg'
        assert_response 200
      end
    end

  end
  
  describe "#asset" do 
    it 'serves file' do
      filename = "asset-test.txt"
      args = { :id=>filename, :format=>'txt', :explicit_file=>true }
      path = File.join( Wagn.paths['gem-assets'].existent.first, filename)
      File.open(path, "w") { |f| f.puts "test" } 
      visit "assets/#{filename}"
      expect(page.body).to eq ("test\n")
      FileUtils.rm path
    end
      
    it 'denies access to other directories' do
      args = { :filename => "/../../Gemfile" }
      get :asset, args 
      expect(response.status).to eq(404)
    end
  end
  describe "unit tests" do

    before do
      @simple_card = Card['Sample Basic']
      login_as 'joe_user'
    end


    describe "#update" do
      it "works" do
        xhr :post, :update, { :id=>"~#{@simple_card.id}",
          :card=>{:current_revision_id=>@simple_card.current_revision.id, :content=>'brand new content' }}
        assert_response :success, "edited card"
        assert_equal 'brand new content', Card['Sample Basic'].content, "content was updated"
      end
      
      it "rename without update references should work" do
        f = Card.create! :type=>"Cardtype", :name=>"Apple"
        xhr :post, :update, :id => "~#{f.id}", :card => {
          :name => "Newt",
          :update_referencers => "false",
        }
        assigns['card'].errors.empty?.should_not be_nil
        assert_response :success
        Card["Newt"].should_not be_nil
      end

      it "update type_code" do
        xhr :post, :update, :id=>"~#{@simple_card.id}", :card=>{ :type=>"Date" }
        assert_response :success, "changed card type"
        Card['Sample Basic'].type_code.should == :date
      end
    end



    it "delete" do
      c = Card.create( :name=>"Boo", :content=>"booya")
      post :delete, :id=>"~#{c.id}"
      assert_response :redirect
      Card["Boo"].should == nil
    end

    it "should comment" do
      Card::Auth.as_bot do
        Card.create :name => 'basicname+*self+*comment', :content=>'[[Anyone Signed In]]'
      end
      post :update, :id=>'basicname', :card=>{:comment => " and more\n  \nsome lines\n\n"}
      cont = Card['basicname'].content
      cont.should =~ /basiccontent/
      cont.should =~ /some lines/
    end

    it "should watch" do
      login_as('joe_user')
      post :watch, :id=>"Home", :toggle=>'on'
      assert c=Card["Home+*watchers"]
      c.content.should == "[[Joe User]]"

      post :watch, :id=>"Home", :toggle=>'off'
      assert c=Card["Home+*watchers"]
      c.content.should == ''
    end



  end
end
