class VerifyPhoneController < ApplicationController
  def create

    account_sid = ENV['TWILIO_ACCOUNT_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    @client = Twilio::REST::Client.new(account_sid, auth_token)

    verification = @client
                     .verify
                     .v2
                     .services(ENV['TWILIO_SERVICE_SID'])
                     .verifications
                     .create(
                       to: '+1' + params[:number],
                       channel: 'sms'
                     )

    puts verification.sid
  end


end
