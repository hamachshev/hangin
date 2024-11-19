class ChatsChannel < ApplicationCable::Channel
  def subscribed

    current_user.update last_foreground: Time.current

    stream_from "chats_channel#{current_user.id}"

    chats = []
    current_user.contacts.each do |contact|
      if (contact.contacts.include? current_user) && (contact.online?) #get all unended chats that current_users contacts have joined
        contact.chats.each do |chat|
          if chat.ended.nil? && !chats.include?(chat) # Avoid duplicates
            chats << chat
          end
        end
      end
    end

    #send all my chats that are still ongoing and i am subbed to
    current_user.chats.each do |chat|
      if chat.ended == nil and !(chats.include? chat)
        chats << chat
      end
    end
    # ActionCable.server.broadcast "chats_channel#{current_user.id}", {chats: chats.map { |chat| chat.id }}

    # transmit({chats: chats.map { |chat| chat.id }})

    transmit({
               chats: chats.map { |chat| {
                 id: chat.id,
                 name: chat.name,
                 users: (chat.users.filter {|user| user.online?}).map {|user|
                 {
                   first_name: user.first_name,
                   last_name: user.last_name,
                   uuid: user.uuid,
                   number: user.number,
                   profile_pic: user.profile_pic.attached? ? Rails.application.routes.url_helpers.rails_blob_url(user.profile_pic) : nil
                 }

               } }}})

    #trnsmit (send to self) all online contacts
    contacts = []
    current_user.contacts.each do |contact|
      if contact.online?
        contacts << {
          first_name: contact.first_name,
          last_name: contact.last_name,
          uuid: contact.uuid,
          number: contact.number,
          profile_pic: contact.profile_pic.attached? ? Rails.application.routes.url_helpers.rails_blob_url(contact.profile_pic) : nil
        }
        unless current_user.messages_as_notifications?
          #send self (online) to contacts
          ActionCable.server.broadcast "chats_channel#{contact.id}", {contactOnline:{
            first_name: current_user.first_name,
            last_name: current_user.last_name,
            uuid: current_user.uuid,
            number: current_user.number,
            profile_pic: current_user.profile_pic.attached? ? Rails.application.routes.url_helpers.rails_blob_url(current_user.profile_pic) : nil
          }}
        end
      end
    end

    current_user.update online: true
      current_user.update messages_as_notifications: false
    transmit({contactsOnline: contacts})
    #send online status to all online contacts

    end


  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    unless current_user.messages_as_notifications?
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
          if chatUsers.count == 0
            chat.update ended: DateTime.current
            #(ActionCable.server.broadcast "chats_channel#{chatUsers[0].id}", {deleteChat: chat.id}) unless chatUsers.count == 0
          end
          chat.users.reload
          current_user.contacts.each do |contact| #not sure if this is right anymore
            if (contact.online?) and !chat.users.include?(contact)
              ActionCable.server.broadcast "chats_channel#{contact.id}", {deleteChat: chat.id}
            end
          end
        end
      end

    end
    # current_user.chats.destroy #Chat.find(params[:id]) #think about this later
  end

  def createChat(data)
    chat = current_user.chats_started.create!
    chat.update name: data['name']
   current_user.chats << chat unless current_user.chats.include? chat
    current_user.contacts.each { |contact|
      contact.reload #need this because otherwise rails uses cached version which is not online when this method is created. without this if you turn on one session before another the second one works and the first one does not
      if contact.online?
        ActionCable.server.broadcast "chats_channel#{contact.id}", {
          chat: { id:chat.id,
                  name: chat.name,
                  users: (chat.users.filter {|user| user.online?}).map {|user|
          {
            first_name: user.first_name,
            last_name: user.last_name,
            uuid: user.uuid,
            number: user.number,
            profile_pic: user.profile_pic.attached? ? Rails.application.routes.url_helpers.rails_blob_url(user.profile_pic) : nil
          }

        }

        }
        }
      end
    }

    transmit({ownChat: {
      id:chat.id,
      name: chat.name,
      users: (chat.users.filter {|user| user.online?}).map {|user|
      {
        first_name: user.first_name,
        last_name: user.last_name,
        uuid: user.uuid,
        number: user.number,
        profile_pic: user.profile_pic.attached? ? Rails.application.routes.url_helpers.rails_blob_url(user.profile_pic) : nil
      }

    }

    }})

  end

  def go_to_background
    current_user.update last_foreground: Time.current
    current_user.update messages_as_notifications: true

    ActionCable.server.remote_connections.where(current_user: current_user).disconnect
    EndMessagesNotificationsJob.set(wait: 5.minutes).perform_later(current_user)

    current_user.chats.each do |chat|
      if chat.ended != nil
        stop_stream_from "chat_channel#{chat.id}"
      end
    end
    stop_stream_from "chats_channel#{current_user.id}"
  end
end
