class ChatChannel < ApplicationCable::Channel
  def subscribed
    chat  = Chat.find(params[:id])
    current_user.chats << chat unless current_user.chats.include? chat # need the unless because otherwize if you make a chat and then subscribe then its in your chats twice and then in subscribed action in chats channel it sends two messages of same chat
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
