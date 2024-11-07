Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  use_doorkeeper

  # Defines the root path route ("/")
  # post "/create" => "verify_phone#create"
  # post "/verify" => "verify_phone#verify"
  # post "/finalize" => "users#add_name"
  patch "/user/" => "users#update"
  get "/user/" => "users#show"

  post "/user/addProfilePicture" => "users#add_picture"
  root "pages#index"

  # get 'storage/*path', to: 'rails/active_storage/blobs#redirect'


end
