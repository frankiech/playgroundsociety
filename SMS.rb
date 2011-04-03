require "twiliolib"

module SMS
  require 'env/load_vars' unless ENV["RACK_ENV"] == "production"

  @twilio_id ||= ENV["TWILIO_ID"]
  @twilio_secret ||= ENV["TWILIO_SECRET"]
  @twilio_phone ||= ENV["TWILIO_PHONE"]

  def self.text(message, opts={})
    twilio = Twilio::RestAccount.new @twilio_id, @twilio_secret
    res = twilio.request "/2010-04-01/Accounts/#{@twilio_id}/SMS/Messages", 'POST',
      'To' => opts[:to],
      'From' => opts[:from] || @twilio_phone,
      'Body' => message
    res.code.to_i == 201 ? true : false
  end
end
