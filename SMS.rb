require "twiliolib"
require "env/load_vars"

module SMS
  @twilio_id = $TWILIO_ID
  @twilio_secret = $TWILIO_SECRET
  @twilio_phone = $TWILIO_PHONE

  def self.text(message, opts={})
    twilio = Twilio::RestAccount.new @twilio_id, @twilio_secret
    res = twilio.request "/2010-04-01/Accounts/#{@twilio_id}/SMS/Messages", 'POST',
      'To' => opts[:to],
      'From' => opts[:from] || @twilio_phone,
      'Body' => message
    res.code.to_i == 201 ? true : false
  end
end
