event :notify_airbrake, :after=>:notable_exception_raised do
  controller.send :notify_airbrake, @exception if Airbrake.configuration.api_key
end
