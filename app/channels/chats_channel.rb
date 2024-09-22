class ChatsChannel < ApplicationCable::Channel
  def subscribed
    current_user.online = true
    stream_from "chats_channel#{current_user.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
