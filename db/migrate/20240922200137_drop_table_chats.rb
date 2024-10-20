class DropTableChats < ActiveRecord::Migration[7.0]
  def change
    drop_table :chats
  end
end
