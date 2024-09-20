class User < ApplicationRecord
  validates :number, uniqueness: true
end
