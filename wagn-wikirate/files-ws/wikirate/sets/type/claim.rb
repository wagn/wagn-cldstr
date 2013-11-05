# changes label of name on claims (should be obviatable)
view :name_editor do |args|
  fieldset 'Claim', raw( name_field form ), :editor=>'name', :help=>args[:help]
end


