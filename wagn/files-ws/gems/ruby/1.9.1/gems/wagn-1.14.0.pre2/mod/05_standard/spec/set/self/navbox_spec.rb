# -*- encoding : utf-8 -*-

describe Card::Set::Self::Navbox do
  it "should have a form" do
    assert_view_select render_card(:raw, :name=>'*navbox'), 'form.navbox-form'
  end
end
