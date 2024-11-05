class ChatsChannel < ApplicationCable::Channel
  def subscribed
    current_user.update online: true
    stream_from "chats_channel#{current_user.id}"

    chats = []
    current_user.contacts.each do |contact|
      if (contact.contacts.include? current_user) && (contact.online?)
        contact.chats.each do |chat|
          if chat.ended == nil
            chats << chat
          end
        end
      end
    end
    # ActionCable.server.broadcast "chats_channel#{current_user.id}", {chats: chats.map { |chat| chat.id }}

    # transmit({chats: chats.map { |chat| chat.id }})

    transmit({
               chats: chats.map { |chat| {id: chat.id, users: (chat.users.filter {|user| user.online?}).map {|user|
                 {
                   first_name: user.first_name,
                   last_name: user.last_name,
                   uuid: user.uuid,
                   number: user.number,
                 }

               } }}})

    #trnsmit (send to self) all online contacts'
    contacts = []
    current_user.contacts.each do |contact|
      if contact.online?
        contacts << contact
        ActionCable.server.broadcast "chats_channel#{contact.id}", {contactOnline:{
          first_name: current_user.first_name,
          last_name: current_user.last_name,
          uuid: current_user.uuid,
          number: current_user.number,
        }}
      end
    end

    transmit({contactsOnline: contacts})
    #send online status to all online contacts


  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    current_user.update online: false
    # current_user.chats.filter { |chat| chat.ended == nil }.each { |chat|
    #   if (chat.users.filter { |user| user.online? }).count <= 1
    #     chat.update ended: DateTime.current
    #   end
    # }

    #update offline status to all contacts

    current_user.contacts.each do |contact|
      contact.reload
      if contact.online?
        ActionCable.server.broadcast "chats_channel#{contact.id}", {contactOffline: current_user.uuid}
      end
    end

    puts "______________________________________"
    puts "unsubscribing..."
    puts "______________________________________"

    current_user.chats.each do |chat|
      if chat.ended == nil
          chatUsers = chat.users.filter { |user| user.online? }
          if chatUsers.count <= 1
            chat.update ended: DateTime.current
            (ActionCable.server.broadcast "chats_channel#{chatUsers[0].id}", {deleteChat: chat.id}) unless chatUsers.count == 0
          end
          current_user.contacts.each do |contact| #not sure if this is right anymore
            if (contact.online?) && !(chat.users.include? contact)
              ActionCable.server.broadcast "chats_channel#{contact.id}", {deleteChat: chat.id}
            end
          end
        end
      end


    # current_user.chats.destroy #Chat.find(params[:id]) #think about this later
  end

  def createChat
    chat = current_user.chats_started.create!
   current_user.chats << chat unless current_user.chats.include? chat
    current_user.contacts.each { |contact|
      contact.reload #need this because otherwise rails uses cached version which is not online when this method is created. without this if you turn on one session before another the second one works and the first one does not
      if contact.online?
        ActionCable.server.broadcast "chats_channel#{contact.id}", {chat: { id:chat.id, users: (chat.users.filter {|user| user.online?}).map {|user|
          {
            first_name: user.first_name,
            last_name: user.last_name,
            uuid: user.uuid,
            number: user.number,
          }

        }

        }
        }
      end
    }

    transmit({ownChat: { id:chat.id, users: (chat.users.filter {|user| user.online?}).map {|user|
      {
        first_name: user.first_name,
        last_name: user.last_name,
        uuid: user.uuid,
        number: user.number,
      }

    }

    }})

  end
end
