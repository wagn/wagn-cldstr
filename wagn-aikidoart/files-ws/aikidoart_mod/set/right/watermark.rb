format :html do
  view :core do |args|
    if !Auth.signed_in?
      args[:size] = :medium if [:large, :full, :original].member?( args[:size] )
    end
    super args
  end  
end