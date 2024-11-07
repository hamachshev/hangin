class AddNameToChat < ActiveRecord::Migration[7.0]
  def change
    add_column :chats, :name, :string, null: false, default: ""
  end
end
