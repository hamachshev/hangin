class Message < ApplicationRecord
  belongs_to :user
  belongs_to :chat
  enum :kind, [:text, :image, :audio, :video]
  enum :status, [:draft, :sent, :delivered]
end
