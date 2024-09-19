class VerifyPhoneController < ApplicationController
  def create

    account_sid = ENV['TWILIO_ACCOUNT_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    @client = Twilio::REST::Client.new(account_sid, auth_token)

    verification = @client
                     .verify
                     .v2
                     .services('VA791034a44b0bc8e4fede66dfb91e7e1a')
                     .verifications
                     .create(
                       to: '+1' + params[:number],
                       channel: 'sms'
                     )

    puts verification.sid
  end

  def verify
    account_sid = ENV['TWILIO_ACCOUNT_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    @client = Twilio::REST::Client.new(account_sid, auth_token)
    verification_check = @client
                           .verify
                           .v2
                           .services('VA791034a44b0bc8e4fede66dfb91e7e1a')
                           .verification_checks
                           .create(
                             to: '+1' + params[:number],
                             code: params[:code]
                           )

    puts verification_check.status
  end
end
