class ChatChannel < ApplicationCable::Channel
  def subscribed
    chat  = Chat.find(params[:id])
    current_user.chats << chat unless current_user.chats.include? chat # need the unless because otherwize if you make a chat and then subscribe then its in your chats twice and then in subscribed action in chats channel it sends two messages of same chat

    #refresh the chats of all the users of the chat
    chat.users.reload
    chat.users.each do |user|
      #send the updated chat to the users of the chat
        ActionCable.server.broadcast "chats_channel#{user.id}", {updateChat: {
          id:chat.id,
          name: chat.name,
          users: (chat.users.filter {|user| user.online?}).map {|user|
          {
            first_name: user.first_name,
            last_name: user.last_name,
            uuid: user.uuid,
            number: user.number,
            profile_pic: user.profile_pic.attached? ? Rails.application.routes.url_helpers.rails_blob_url(user.profile_pic, disposition: "inline") : nil
          }

        }

        }}
      #send the updated chat to the user's contacts if they are not members of the chat
      user.contacts.each do |contact|
        ActionCable.server.broadcast "chats_channel#{contact.id}", {updateChat: {
          id:chat.id,
          name: chat.name,
          users: (chat.users.filter {|user| user.online?}).map {|user|
          {
            first_name: user.first_name,
            last_name: user.last_name,
            uuid: user.uuid,
            number: user.number,
            profile_pic: user.profile_pic.attached? ?Rails.application.routes.url_helpers.rails_blob_url(user.profile_pic, disposition: "inline") : nil
          }

        }
        }} unless contact.chats.include? chat
      end
    end
    stream_from "chat_channel#{params[:id]}"
    messages = Chat.find(params[:id]).messages.map do |message|
      {
        user_uuid: message.user_uuid,
        kind: message.kind,
        first_name: message.user.first_name,
        last_name: message.user.last_name,
        body: message.body
      }
    end
    transmit({messages:})
  end

  def unsubscribed


    # puts "______________________________________"
    # puts "unsubscribing... from chat " + @chat.id.to_s
    # puts "______________________________________"
    #
    #   if (@chat.users.filter { |user| user.online? }).count <= 1
    #     ActionCable.server.broadcast "chats_channel#{current_user.id}", {deleteChat: @chat.id}
    #     @chat.update ended: DateTime.current
    #   end

    end


  def speak(data)
    message = Chat.find(params[:id]).messages.create! user_id: current_user.id, body: data['body'],kind: data['kind'].to_sym, status: data['status'].to_sym, user_uuid: current_user.uuid
    ActionCable.server.broadcast "chat_channel#{params[:id]}", {message: {
      user_uuid: message.user_uuid,
      kind: message.kind,
      first_name: message.user.first_name,
      last_name: message.user.last_name,
      body: message.body
    }}
  end
end
