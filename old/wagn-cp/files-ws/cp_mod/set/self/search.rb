format :json do
  def goto_wql(term)
    xtra = search_params
    xtra.delete :default_limit
    xtra.merge( { :complete=>term, :limit=>8, :sort=>'name', :return=>'name' } )
  end
end