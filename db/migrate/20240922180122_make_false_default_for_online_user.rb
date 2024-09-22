class MakeFalseDefaultForOnlineUser < ActiveRecord::Migration[7.0]
  def change
    change_column_default :users, :online, false
  end
end
