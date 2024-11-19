class AddMessagesAsNotificationsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :messages_as_notifications, :boolean, default: false
  end
end
