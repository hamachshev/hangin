class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_channel#{params[:id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    message = Chat.find(params[:id]).messages.create! user_id: current_user.id, body: data['body'],kind: data['kind'].to_sym, status: data['status'].to_sym
    ActionCable.server.broadcast "chat_channel#{params[:id]}", {message:}
  end
end
