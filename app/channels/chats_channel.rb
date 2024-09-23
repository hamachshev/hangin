class ChatsChannel < ApplicationCable::Channel
  def subscribed

    current_user.update online: true
    stream_from "chats_channel#{current_user.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    current_user.update online: false
  end

  def createChat
    chat = current_user.chats_started.create!
    current_user.contacts.each { |contact|
      if contact.online?
        ActionCable.server.broadcast "chats_channel#{contact.id}", { id: chat.id}
      end
    }

  end
end
