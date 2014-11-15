# -*- encoding : utf-8 -*-

describe Card::Set::All::Content do
  describe 'save_content_draft' do
    it 'should store a draft revision' do
      @card = Card.create! :name=>"mango", :content=>"foo"
      @card.save_content_draft("bar")
      expect(@card.drafts.length).to eq 1
      @card.save_content_draft("booboo")
      @card.reload
      expect(@card.drafts.length).to eq 1
      expect(@card.drafts[0].new_values[:content]).to eq "booboo"
    end
  end
end
