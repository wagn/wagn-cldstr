describe Card::Set::Type::JavaScript do
  let(:js)                    { 'alert( "Hi" );'    }
  let(:compressed_js)         { 'alert("Hi");'      }
  let(:changed_js)            { 'alert( "Hello" );' }
  let(:compressed_changed_js) { 'alert("Hello");'   }


  it_should_behave_like 'content machine', that_produces_js do
    let(:machine_card)  { Card.gimme! "test javascript", :type => :java_script, :content => js}
    let(:card_content) do
       { in:       js,         out:     compressed_js, 
         changed_in:   changed_js, changed_out: compressed_changed_js }
    end
  end

  it_behaves_like "machine input"  do
    let(:create_machine_input_card) { Card.gimme! "test javascript", :type => :java_script, :content => js }
    let(:create_another_machine_input_card) { Card.gimme! "more javascript", :type => :java_script, :content => js }
    let(:create_machine_card)  { Card.gimme! "script with js+*script", :type => :pointer }
    let(:card_content) do
       { in:       js,         out:     compressed_js, 
         changed_in:   changed_js, changed_out: compressed_changed_js }
    end
  end

end