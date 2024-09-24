class Chat < ApplicationRecord
  has_one :started_by, class_name: "User"
  has_many :messages

  has_and_belongs_to_many :users
end
