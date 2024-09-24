class ChatsChannel < ApplicationCable::Channel
  def subscribed
    current_user.update online: true
    stream_from "chats_channel#{current_user.id}"

    chats = []
    current_user.contacts.each do |contact|
      if contact.online == true && contact.chats.count >= 1
        contact.chats.each do |chat|
          chats << chat
        end
      end
    end
    # ActionCable.server.broadcast "chats_channel#{current_user.id}", {chats: chats.map { |chat| chat.id }}
    transmit({chats: chats.map { |chat| chat.id }})
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    current_user.update online: false
  end

  def createChat
    chat = current_user.chats_started.create!
    current_user.chats << chat
    current_user.contacts.each { |contact|
      if contact.online?
        ActionCable.server.broadcast "chats_channel#{contact.id}", { chat: {id: chat.id}}
      end
    }

    transmit({chat: chat.id})

  end
end
