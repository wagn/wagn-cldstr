# -*- encoding : utf-8 -*-

describe Card::Set::Type::Html do
  before do
    Card::Auth.current_id = Card::WagnBotID
  end

  it "should have special editor" do
    assert_view_select render_editor('Html'), 'textarea[rows="5"]'
  end

  it "should not render any content in closed view" do
    render_card(:closed_content, :type=>'Html', :content=>"<strong>Lions and Tigers</strong>").should == ''
  end

  it "should render inclusions" do
    render_card( :core, :type=>'HTML', :content=>'{{a}}' ).should =~ /slot/
  end

  it 'should not render uris' do
    render_card( :core, :type=>'HTML', :content=>'http://google.com' ).should_not =~ /\<a/
  end
end
