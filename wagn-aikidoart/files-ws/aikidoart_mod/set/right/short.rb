format :html do
  view :core do |args|
    add_name_context
    super args
  end
end