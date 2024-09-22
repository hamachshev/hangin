class MakeContactsJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_table :contacts, id: false do |t|
      t.integer :user_id, null: false
      t.integer :contact_id, null: false
    end
  end
end
