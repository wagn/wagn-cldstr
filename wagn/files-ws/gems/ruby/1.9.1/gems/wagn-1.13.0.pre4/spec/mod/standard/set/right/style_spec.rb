# -*- encoding : utf-8 -*-

require File.expand_path('../../../lib/machine_spec.rb', __FILE__)

describe Card::Set::Right::Style do
#  describe "#delet"
#  it "should delete tempfile"
  #let!(:skin_card)              { Card.gimme! "test skin", :type => :skin, :content => '[[test css]]'}
  let(:css)                    { "#box { display: block }"  }
  let(:compressed_css)         { "#box{display:block}\n"    }
  let(:changed_css)            { "#box { display: inline }" }
  let(:compressed_changed_css) { "#box{display:inline}\n"   }
  let(:new_css)                { "#box{ display: none}\n"   }
  let(:compressed_new_css)     { "#box{display:none}\n"   }  
  
  it_should_behave_like 'pointer machine', that_produces_css do
    let(:machine_card)  { Card.gimme! "test my style+*style", :type => :pointer, :content => ''}
    let(:machine_input_card) { Card.gimme! "test css",  :type => :css, :content => css  }
    let(:another_machine_input_card) { Card.gimme! "more css",  :type => :css, :content => new_css  }
    let(:expected_input_items) { nil } #[Card.fetch("test skin"), machine_input_card] }
    let(:input_type) { :css }
    let(:card_content) do
       { in:           css,         out:     compressed_css, 
         changed_in:   changed_css, changed_out: compressed_changed_css,
         new_in:       new_css,     new_out:     compressed_new_css
       }
    end
  end
end
