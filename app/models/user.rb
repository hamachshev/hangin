class User < ApplicationRecord
  validates :number, uniqueness: true
  has_and_belongs_to_many :contacts,
                          class_name: "User",
                          join_table: "contacts",
                          foreign_key: "user_id",
                          association_foreign_key: "contact_id"
  has_many :chats_started, class_name: "Chat"
  has_many :messages
  has_and_belongs_to_many :chats

  has_one_attached :profile_pic
  has_many :friends

end
