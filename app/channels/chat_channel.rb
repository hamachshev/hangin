class ChatChannel < ApplicationCable::Channel
  def subscribed
    chat  = Chat.find(params[:id])
    current_user.chats << chat
    stream_from "chat_channel#{params[:id]}"
    transmit({messages: Chat.find(params[:id]).messages})
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
    ActionCable.server.broadcast "chat_channel#{params[:id]}", {message:}
  end
end
