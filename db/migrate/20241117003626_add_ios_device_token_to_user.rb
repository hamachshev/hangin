class AddIosDeviceTokenToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :ios_device_token, :string
  end
end
