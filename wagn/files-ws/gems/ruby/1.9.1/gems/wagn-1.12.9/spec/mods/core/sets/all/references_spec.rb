# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::All::References do
  it "should replace references should work on inclusions inside links" do
    card = Card.create!(:name=>"test", :content=>"[[test_card|test{{test}}]]"  )
    assert_equal "[[test_card|test{{best}}]]", card.replace_references("test", "best" )
  end
end
