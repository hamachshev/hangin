class ChatsChannel < ApplicationCable::Channel
  def subscribed
    current_user.online = true
    stream_from "chats_channel#{current_user.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def createChat
    chat = current_user.chats_started.create!
    current_user.contacts.each { |contact|
      if contact.online?
        ActionCable.server.broadcast "chats_channel#{contact.id}", data: chat.id
      end
    }

  end
end
