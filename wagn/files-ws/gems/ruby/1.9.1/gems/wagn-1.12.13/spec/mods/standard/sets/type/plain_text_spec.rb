# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::Type::PlainText do
  it "should have special editor" do
    assert_view_select render_editor('Plain Text'), 'textarea[rows="5"]'
  end

  it "should have special content that escapes HTML" do
    render_card(:core, :type=>'Plain Text', :content=>"<b></b>").should == '&lt;b&gt;&lt;/b&gt;'
  end
end
