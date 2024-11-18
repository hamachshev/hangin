class NotificationsController < ApplicationController
  before_action :doorkeeper_authorize!

  def sendInviteNotification
    if params[:users_to_invite].present?
      params[:users_to_invite].each do |userToInviteUUID|
        contact = user.contacts.find_by(uuid: userToInviteUUID)
        if contact&.ios_device_token
          notification = Apnotic::Notification.new contact.ios_device_token
          notification.alert = {title: "Live chat invite! 🎉", body: "#{user.first_name} #{user.last_name} wants to chat with you!\nTap to chat"}
          notification.sound = "default"
          notification.topic = ENV['IOS_APP_IDENTIFIER']
          notification.custom_payload = {chat: params[:chat_id]}

          push = APNS_CONNECTION.prepare_push(notification)
          push.on(:response) do |response|
            print("recived APNS response")
            print( response.status)
            print(response.body)
          end

          APNS_CONNECTION.push_async(push)
        end
      end
    end

  end

  private

  def user
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
