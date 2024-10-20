class AddUserUuidToMessage < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :user_uuid, :string
  end
end
