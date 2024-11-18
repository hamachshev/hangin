Rails.application.routes.draw do


  resources :friends, only: [:index, :create]
  # get "/contacts", to: "friends#get_contacts"
  mount ActionCable.server => '/cable'

  use_doorkeeper

  # Defines the root path route ("/")
  post "/create" => "verify_phone#create"
  # post "/verify" => "verify_phone#verify"
  # post "/finalize" => "users#add_name"
  patch "/user/" => "users#update"
  get "/user/" => "users#show"

  post "/user/addProfilePicture" => "users#add_picture"
  post "/user/registerIOSDevice" => "users#registerIOSDevice"
  post "/notifications/invite" => "notifications#sendInviteNotification"
  root "pages#index"

  # get 'storage/*path', to: 'rails/active_storage/blobs#redirect'


end
