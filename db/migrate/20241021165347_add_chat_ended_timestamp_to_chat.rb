class AddChatEndedTimestampToChat < ActiveRecord::Migration[7.0]
  def change
    add_column :chats, :ended, :datetime
  end
end
