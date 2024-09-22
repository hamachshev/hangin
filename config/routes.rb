Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  use_doorkeeper

  # Defines the root path route ("/")
  post "/create" => "verify_phone#create"
  # post "/verify" => "verify_phone#verify"
  post "/finalize" => "users#add_name"


end
