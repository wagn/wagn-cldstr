event :set_log_date_name, :before=>:approve, :on=>:create do
  if name.blank?
    date = Env.params[:tomorrow] ? :tomorrow : :today
    self.name = ::Date.send(date).to_s.gsub '-', ''
  end
end