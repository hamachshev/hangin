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

    if verification_check.status == "approved"
      user = User.find_by(number: params[:number])
      if user.nil?
        user = User.create(number: params[:number])
      end

      access_token = Doorkeeper::AccessToken.find_by(resource_owner_id: user.id) || Doorkeeper::AccessToken.create(
        resource_owner_id: user.id,
        refresh_token: Doorkeeper::OAuth::Helpers::UniqueToken.generate,
        expires_in: Doorkeeper.configuration.access_token_expires_in.to_i,
        scopes: ''
      )

      render json: {
        access_token: access_token.token,
        token_type: 'bearer',
        expires_in: access_token.expires_in,
        refresh_token: access_token.refresh_token,
        created_at: access_token.created_at.to_time.to_i,
        first_name: user.first_name,
        last_name: user.last_name
      }, status: :ok

      else render json: {error: "Invalid verification code."}, status: :unauthorized
      # render json: user.to_json(only: [:uuid, :first_name, :last_name, :number])
    end

  end
end
