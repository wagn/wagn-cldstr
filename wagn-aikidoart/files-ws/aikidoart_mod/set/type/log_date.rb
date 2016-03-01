event :set_log_date_name, :prepare_to_validate, on: :create do
  if name.blank?
    date = Env.params[:tomorrow] ? :tomorrow : :today
    self.name = ::Date.send(date).to_s.delete '-'
  end
end
