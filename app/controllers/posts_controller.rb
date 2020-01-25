# class PostsController < ApplicationController
# end

module PostsController
    GET_POSTS_LIMIT = 30 # Maximum posts that server will get from database

    # Show all posts in range (max 30) ordered by creation time. Format: subforum/:id/posts?start=n&end=nn
    def show_subforum_posts
        status, data = ApplicationController.check_rights(params, session, UserGroup::RightFlags::THREAD_READ) { |status, params, session|
            id = params[:id].to_i
            start_pos = params[:start].to_i || GET_POSTS_LIMIT
            end_pos = params[:end].to_i

            if start_pos > GET_POSTS_LIMIT
                start_pos = GET_POSTS_LIMIT
            end

            if !SubForum.exists?(id: id)
                status = :not_found # Sub Forum doesn't exist
            else
                query = if end_pos != 0
                    Post.escape_sql(["SELECT `posts`.* FROM `posts` WHERE subforum = ? ORDER BY `posts`.`created_at` ASC LIMIT ?, ?", id, start_pos, end_pos])
                else
                    Post.escape_sql(["SELECT `posts`.* FROM `posts` WHERE subforum = ? ORDER BY `posts`.`created_at` ASC LIMIT ?", id, start_pos])
                end
                data = Post.find_by_sql query
            end

            [status, data]
        }
        render json: {data: data}, status: status
    end

    def show_post
        status, data = ApplicationController.check_rights(params, session, UserGroup::RightFlags::THREAD_READ) { |status, params, session|
            id = params[:id].to_i
            post_id = params[:post].to_i

            post = Post.find_by("id = ? AND subforum = ?", post_id, id)

            if !SubForum.exists?(id: id) || !post.blank?
                status = :not_found # Sub Forum or Post doesn't exist
            end

            [status, post]
        }
        render json: {data: data}, status: status
    end

    def create_post
        status, data = ApplicationController.check_rights(params, session, UserGroup::RightFlags::THREAD_CREATE) { |status, params, session, user|
            id = params[:id].to_i
            title = params[:title]
            content = params[:content]
            icon = params[:icon]

            if id.blank? || title.blank? || content.blank? || user.blank? || (icon && !ApplicationController::Icons.has_value?(icon))
                status = :bad_request
            elsif !SubForum.exists?(id: id)
                status = :not_found # Sub Forum doesn't exist
            else
                post = Post.create(
                    title: title,
                    content: content,
                    subforum: id,
                    creatorSteamID: user.steamID
                )
                post.icon = icon if icon
                post.save!

                forum = SubForum.find id
                forum_posts = JSON.parse forum.threads
                forum_posts.push post.id
                forum.threads = forum_posts.to_json
                forum.save!
            end

            [status, data]
        }
        render status: status
    end

    def update_post
        status, data = ApplicationController.check_rights(params, session, UserGroup::RightFlags::THREAD_MODIFY) { |status, params, session, user|
            id = params[:id].to_i
            post_id = params[:post].to_i
            title = params[:title]
            content = params[:content]
            icon = params[:icon]

            if id.blank? || title.blank? || content.blank? || user.blank? || !ApplicationController::Icons.has_value?(icon)
                status = :bad_request
            elsif !SubForum.exists?(id: id) || !Post.find_by("id = ? AND subforum = ?", post_id, id).exists?
                status = :not_found # Sub Forum or Post doesn't exist
            else
                post = Post.find(id)

                if user.steamID == post.creatorSteamID
                    post.title = title
                    post.content = content
                    post.icon = icon
                    post.save!
                else
                    status = :forbidden
                end
            end

            [status, data]
        }
        render status: status
    end

    def destroy_post
        # First check right for deletion your own threads
        status, data = ApplicationController.check_rights(params, session, UserGroup::RightFlags::THREAD_DELETE_OWN) { |status, params, session, user|
            subforum_id = params[:id].to_i
            post_id = params[:post].to_i

            if subforum_id.blank? || post_id.blank?
                status = :bad_request
            elsif !SubForum.exists?(id: subforum_id)
                status = :not_found # Sub Forum doesn't exist
            else
                begin
                    post = Post.find_by "id = ? AND subforum = ?", post_id, subforum_id
                    if post.creatorSteamID == user.steamID
                        forum = SubForum.find subforum_id
                        forum_posts = JSON.parse forum.threads
                        forum_posts.delete post.id
                        forum.posts = forum_posts.to_json
                        forum.save!

                        post.destroy
                    else
                        status = :forbidden
                    end
                rescue ActiveRecord::RecordNotFound
                    status = :not_found
                end
            end

            [status, data]
        }

        # If you're not creator or you don't have a right to delete your own threads
        # We check right for just thread deletion
        if status == :unauthorized
            status, data = ApplicationController.check_rights(params, session, UserGroup::RightFlags::THREAD_DELETE) { |status, params, session|
                subforum_id = params[:id].to_i
                post_id = params[:post].to_i

                if subforum_id.blank? || post_id.blank?
                    status = :bad_request
                elsif !SubForum.exists?(id: subforum_id)
                    status = :not_found # Sub Forum doesn't exist
                else
                    begin
                        post = Post.find_by "id = ? AND subforum = ?", post_id, subforum_id

                        forum = SubForum.find subforum_id
                        forum_posts = JSON.parse forum.threads
                        forum_posts.delete post.id
                        forum.posts = forum_posts.to_json
                        forum.save!

                        # Delete all comments
                        comments = JSON.parse post.comments
                        comments.each do |comment_id|
                            comment = Comment.find_by thread: comment_id
                            comment.delete if comment
                        end

                        post.destroy
                    rescue ActiveRecord::RecordNotFound
                        status = :not_found
                    end
                end

                [status, data]
            }
        end
        render status: status
    end

    def upvote_post
        status, data = ApplicationController.check_rights(params, session, UserGroup::RightFlags::USER_CAN_UPVOTE) { |status, params, session, user|
            post_id = params[:post].to_i
            begin
                post = Post.find post_id
            rescue ActiveRecord::RecordNotFound
                status = :not_found
            else
                upvoted = JSON.parse user.postsUpvoted

                if !upvoted.include? post.id
                    post.upvotes += 1
                    post.save!

                    if user
                        upvoted.push post.id
                        user.postsUpvoted = upvoted.to_json
                        user.save!
                    end

                    creator = User.find_by steamID: post.creatorSteamID

                    if creator && creator.steamID != user.steamID
                        creator.karma += 1
                        creator.save!
                    end
                end
            end
            [status, data]
        }
        render status: status
    end

    def downvote_post
        status, data = ApplicationController.check_rights(params, session, UserGroup::RightFlags::USER_CAN_UPVOTE) { |status, params, session, user|
            post_id = params[:post].to_i
            begin
                post = Post.find post_id
            rescue ActiveRecord::RecordNotFound
                status = :not_found
            else
                downvoted = JSON.parse user.postsDownvoted

                if !downvoted.include? post.id
                    post.downvotes += 1
                    post.save!

                    if user
                        downvoted.push post.id
                        user.postsDownvoted = downvoted.to_json
                        user.save!
                    end

                    creator = User.find_by steamID: post.creatorSteamID

                    if creator && creator.steamID != user.steamID
                        creator.karma -= 1
                        creator.save!
                    end
                end
            end
            [status, data]
        }
        render status: status
    end
end
