Rails.application.routes.draw do
  root "application#stub"
  resources :sub_forum
  get "/sub_forum/:id/posts(.:format)" => "sub_forum#show_subforum_posts"
  get "/sub_forum/:id/post/:post" => "sub_forum#show_post"
  post "/sub_forum/:id/post/create(.:format)" => "sub_forum#create_post"
  post "/sub_forum/:id/post/:post/delete" => "sub_forum#destroy_post"
  post "/sub_forum/:id/post/:post/upvote" => "sub_forum#upvote_post"
  post "/sub_forum/:id/post/:post/downvote" => "sub_forum#downvote_post"

  get "/sub_forum/:id/post/:post/comments(.:format)" => "sub_forum#show_post_comments"
  get "/sub_forum/:id/post/:post/comment/:comment" => "sub_forum#show_comment"
  post "/sub_forum/:id/post/:post/comment/create(.:format)" => "sub_forum#create_comment"
  post "/sub_forum/:id/post/:post/comment/:comment/delete" => "sub_forum#destroy_comment"
  post "/sub_forum/:id/post/:post/comment/:comment/upvote" => "sub_forum#upvote_comment"
  post "/sub_forum/:id/post/:post/comment/:comment/downvote" => "sub_forum#downvote_comment"

  post "/auth/steam/callback" => "user#create"
  post "/logout" => "user#destroy_session"

  resources :user_group
  post "/user_group/configure" => "user_group/configure"
end
