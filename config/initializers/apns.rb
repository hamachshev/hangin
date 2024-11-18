if Rails.env.development?
  APNS_CONNECTION = Apnotic::Connection.development(
    auth_method: :token,
    cert_path: ENV['APNS_AUTHKEY'],
    key_id: ENV['APNS_AUTHKEY_ID'],
    team_id: ENV['APPLE_DEV_TEAM_ID'],
    )
else if Rails.env.production?
  APNS_CONNECTION = Apnotic::Connection.new(
    auth_method: :token,
    cert_path: ENV['APNS_AUTHKEY'],
    key_id: ENV['APNS_AUTHKEY_ID'],
    team_id: ENV['APPLE_DEV_TEAM_ID'],
    )
  end
end
