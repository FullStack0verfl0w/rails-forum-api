Rails.application.routes.draw do
  resources :sub_forum
  root "application#not_found"
  post "/auth/steam/callback" => "user#create"
  post "/logout" => "user#destroy_session"
end
