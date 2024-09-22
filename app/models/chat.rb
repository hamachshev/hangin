class Chat < ApplicationRecord
  has_one :started_by, class_name: "User"
end
