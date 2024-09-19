Rails.application.routes.draw do
  use_doorkeeper

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  post "/create" => "verify_phone#create"
  post "/verify" => "verify_phone#verify"
  post "/finalize" => "users#add_name"
end
