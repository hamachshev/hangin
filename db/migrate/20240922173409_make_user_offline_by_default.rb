class MakeUserOfflineByDefault < ActiveRecord::Migration[7.0]
  def change
    change_column_null :users, :online, false, false
  end
end
