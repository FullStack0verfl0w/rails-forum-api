Rails.application.routes.draw do
  resources :sub_forum
  get "/sub_forum/:id/posts(.:format)" => "sub_forum#show_subforum_posts"
  get "/sub_forum/:id/posts/:post" => "sub_forum#show_post"
  post "/sub_forum/:id/posts/create(.:format)" => "sub_forum#create_post"
  post "/sub_forum/:id/posts/delete/:post(.:format)" => "sub_forum#destroy_post"
  post "/sub_forum/:id/posts/upvote/:post" => "sub_forum#upvote_post"
  post "/sub_forum/:id/posts/downvote/:post" => "sub_forum#downvote_post"

  root "application#stub"

  post "/auth/steam/callback" => "user#create"
  post "/logout" => "user#destroy_session"

  resources :user_group
  post "/user_group/configure" => "user_group/configure"
end
