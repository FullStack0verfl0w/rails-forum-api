# class CommentsController < ApplicationController
# end

module CommentsController
    GET_COMMENTS_LIMIT = 30 # Maximum comments that server will get from database

    # Show all comments in post in range (max 30) ordered by creation time. Format: subforum/:id/posts/:post_id/comments?start=n&end=nn
    def show_post_comments
        status, data = ApplicationController.check_rights(params, session, UserGroup::RightFlags::COMMENT_READ) { |status, params, session|
            post_id = params[:post].to_i
            start_pos = params[:start].to_i
            end_pos = params[:end].to_i

            if !start_pos || ( start_pos > GET_COMMENTS_LIMIT )
                start_pos = GET_COMMENTS_LIMIT
            end

            if !Post.exists? id: post_id
                status = :not_found # Post doesn't exist
            else
                query = if end_pos != 0
                    Post.escape_sql(["SELECT `comments`.* FROM `comments` WHERE thread = ? ORDER BY `comments`.`created_at` ASC LIMIT ?, ?", post_id, start_pos, end_pos])
                else
                    Post.escape_sql(["SELECT `comments`.* FROM `comments` WHERE thread = ? ORDER BY `comments`.`created_at` ASC LIMIT ?", post_id, start_pos])
                end
                data = Post.find_by_sql query
            end

            [status, data]
        }
        render json: {data: data}, status: status
    end

    def show_comment
        status, data = ApplicationController.check_rights(params, session, UserGroup::RightFlags::COMMENT_READ) { |status, params, session|
            post_id = params[:post].to_i
            comment_id = params[:comment].to_i

            comment = Comment.find_by("id = ? AND thread = ?", comment_id, post_id)

            if !Post.exists?(id: post_id) || comment.blank?
                status = :not_found # Sub Forum or Post doesn't exist
            end

            [status, comment]
        }
        render json: {data: data}, status: status
    end

    def create_comment
        status, data = ApplicationController.check_rights(params, session, UserGroup::RightFlags::COMMENT_CREATE) { |status, params, session, user|
            post_id = params[:id].to_i
            content = params[:content] || ""

            if post_id.blank? || content.blank?
                status = :bad_request
            elsif !Post.exists?(id: post_id)
                status = :not_found # Sub Forum doesn't exist
            else
                comment = Comment.create(
                    content: content,
                    thread: post_id,
                    creatorSteamID: user.steamID
                )
                comment.save!

                post = Post.find post_id
                post_comments = JSON.parse post.comments
                post_comments.push comment.id
                post.comments = post_comments.to_json
                post.save!
            end

            [status, data]
        }
        render status: status
    end

    def update_comment
        status, data = ApplicationController.check_rights(params, session, UserGroup::RightFlags::COMMENT_MODIFY) { |status, params, session, user|
            post_id = params[:post].to_i
            comment_id = params[:comment].to_i
            content = params[:content]

            if comment_id.blank? || content.blank? || user.blank?
                status = :bad_request
            elsif !Post.exists?(id: id) || !Comment.find_by("id = ? AND thread = ?", comment_id, post_id).exists?
                status = :not_found # Post or Comment doesn't exist
            else
                comment = Comment.find(id)

                if user.steamID == comment.creatorSteamID
                    comment.content = content
                    comment.save!
                else
                    status = :forbidden
                end
            end

            [status, data]
        }
        render status: status
    end

    def destroy_comment
        # First check right for deletion your own threads
        status, data = ApplicationController.check_rights(params, session, UserGroup::RightFlags::COMMENT_DELETE_OWN) { |status, params, session, user|
            post_id = params[:post].to_i
            comment_id = params[:comment].to_i

            if post_id.blank? || comment_id.blank?
                status = :bad_request
            elsif !Post.exists?(id: post_id)
                status = :not_found # Post doesn't exist
            else
                begin
                    comment = Comment.find_by "id = ? AND thread = ?", comment_id, post_id
                    if comment.creatorSteamID == user.steamID
                        post = Post.find post_id
                        post_comments = JSON.parse post.comments
                        post_comments.delete comment.id
                        post.comments = post_comments.to_json
                        post.save!

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
        if status == :forbidden
            status, data = ApplicationController.check_rights(params, session, UserGroup::RightFlags::COMMENT_DELETE) { |status, params, session|
                post_id = params[:post].to_i
                comment_id = params[:comment].to_i

                if comment_id.blank? || post_id.blank?
                    status = :bad_request
                elsif !Post.exists?(id: post_id)
                    status = :not_found # Post doesn't exist
                else
                    begin
                        comment = Comment.find_by "id = ? AND thread = ?", comment_id, post_id

                        post = Post.find post_id
                        post_comments = JSON.parse post.threads
                        post_comments.delete post.id
                        post.comments = post_comments.to_json
                        post.save!

                        comment.destroy
                    rescue ActiveRecord::RecordNotFound
                        status = :not_found
                    end
                end

                [status, data]
            }
        end
        render status: status
    end

    def upvote_comment
        status, data = ApplicationController.check_rights(params, session, UserGroup::RightFlags::USER_CAN_UPVOTE) { |status, params, session, user|
            comment_id = params[:comment].to_i
            begin
                comment = Comment.find comment_id
            rescue ActiveRecord::RecordNotFound
                status = :not_found
            else
                upvoted = JSON.parse user.commentsUpvoted

                if !upvoted.include? comment.id
                    comment.upvotes += 1
                    comment.save!

                    if user
                        upvoted.push comment.id
                        user.commentsUpvoted = upvoted.to_json
                        user.save!
                    end

                    creator = User.find_by steamID: comment.creatorSteamID

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

    def downvote_comment
        status, data = ApplicationController.check_rights(params, session, UserGroup::RightFlags::USER_CAN_UPVOTE) { |status, params, session, user|
            comment_id = params[:comment].to_i
            begin
                comment = Comment.find comment_id
            rescue ActiveRecord::RecordNotFound
                status = :not_found
            else
                downvoted = JSON.parse user.commentsDownvoted

                if !downvoted.include? comment.id
                    comment.downvotes += 1
                    comment.save!

                    if user
                        downvoted.push comment.id
                        user.commentsDownvoted = downvoted.to_json
                        user.save!
                    end

                    creator = User.find_by steamID: comment.creatorSteamID

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
