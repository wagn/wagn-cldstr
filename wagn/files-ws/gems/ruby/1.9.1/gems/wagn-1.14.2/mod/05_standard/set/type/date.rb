
format :html do

  # what is this for?  Can't you just use TYPE-date and editor to match this cas, no special view needed?
  view :editor do |args|
    form.text_field :content, :class=>'date-editor'
  end
end
