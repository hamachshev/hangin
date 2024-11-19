class EndMessagesNotificationsJob < ApplicationJob
  queue_as :default

  def perform(user)
    print("hello")
    if user.last_foreground&.<= 1.minute.ago #change to 5 minutes
      user.update messages_as_notifications: false
      #basically unsubscribe him without actually being subbed to a channel at this point
      user.update online: false


      user.contacts.each do |contact|
        contact.reload
        if contact.online?
          ActionCable.server.broadcast "chats_channel#{contact.id}", {contactOffline: user.uuid}
        end
      end

      puts "______________________________________"
      puts "unsubscribing..."
      puts "______________________________________"

      user.chats.each do |chat|
        if chat.ended == nil
          chatUsers = chat.users.filter { |chatUser| chatUser.online? }
          if chatUsers.count == 0
            chat.update ended: DateTime.current
            #(ActionCable.server.broadcast "chats_channel#{chatUsers[0].id}", {deleteChat: chat.id}) unless chatUsers.count == 0
          end
          chat.users.reload
          user.contacts.each do |contact| #not sure if this is right anymore
            if (contact.online?) and !chat.users.include?(contact)
              ActionCable.server.broadcast "chats_channel#{contact.id}", {deleteChat: chat.id}
            end
          end
        end
      end


    end
  end
end
