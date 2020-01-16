class SubForumController < ApplicationController
    def index
        now = Time::now
        token = session[:token]
        status = :ok

        # Check token and find user with it
        if token
            user = User.where("session = ? AND sessionEnd > ?", token, now).first
        end

        # Get all records from database
        begin
            #                   Compute flag right here
            data = SubForum.where("rightFlags & ? = ?", User::RightFlags::FORUM_READ, User::RightFlags::FORUM_READ)

        # Tell a client something went wrong
        rescue Exception => e
            puts e.message
            status = :internal_server_error
        else

            # Check client's right flag if client is authorized
            if user
                user_has_read_flag = User::RightFlags.bit_set(user.rightFlags, User::RightFlags::FORUM_READ)

                # If client has no flag, return nothing
                if !user_has_read_flag
                    data = []
                end
            end
        end

        # Regenerate session token
        if user
            user.session = user.generate_token
            user.sessionEnd = now + User::SESSION_EXPIRY_TIME
            user.lastActivityTime = now
            user.save!
            session[:token] = user.session
            session[:expires_at] = user.sessionEnd
        end
        render json: {data: data}, status: status
    end

    def create
        now = Time::now
        token = session[:token]
        status = :ok

        if token
            user = User.where("session = ? AND sessionEnd > ?", token, now).first

            if user && User::RightFlags.bit_set(user.rightFlags, User::RightFlags::FORUM_CREATE)
                name = params[:title] || ""
                desc = params[:desc] || ""
                icon = params[:icon] || SubForum::ICONS[0]
                flag = params[:flag] || User::RightFlags::FORUM_READ

                # Find already existing sub forum
                forum = SubForum.where(name: name).first

                if forum
                    status = :bad_request

                # Check name length
                elsif name.length < SubForum::TITLE_MIN_LEN && SubForum::TITLE_MIN_LEN != -1
                    status = :bad_request
                elsif name.length > SubForum::TITLE_MAX_LEN && SubForum::TITLE_MAX_LEN != -1
                    status = :bad_request

                # Check description length
                elsif desc.length < SubForum::DESC_MIN_LEN && SubForum::DESC_MIN_LEN != -1
                    status = :bad_request
                elsif desc.length > SubForum::DESC_MAX_LEN && SubForum::DESC_MAX_LEN != -1
                    status = :bad_request

                # If everything is alright create record in database
                else
                    forum = SubForum.create(
                        name: name,
                        description: desc,
                        icon: icon,
                        rightFlags: flag,
                        posts: [].to_json
                    )
                    forum.save!
                end

                # Regenerate session token
                user.session = user.generate_token
                user.sessionEnd = now + User::SESSION_EXPIRY_TIME
                user.lastActivityTime = now
                user.save!
                session[:token] = user.session
                session[:expires_at] = user.sessionEnd
            else
                status = :unauthorized
            end
        else
            status = :unauthorized
        end
        render status: status
    end

    def show
        now = Time::now
        id = params[:id]
        token = session[:token]
        status = :ok

        # Check token and find user with it
        if token
            user = User.where("session = ? AND sessionEnd > ?", token, now).first
        end

        # Get a record from database by id
        begin
            forum = SubForum.find(id)

        # Tell client we're not found record
        rescue ActiveRecord::RecordNotFound
            status = :not_found
        rescue Exception => e
            puts e.message
            status = :internal_server_error
        else
            if user
                user_has_read_flag = User::RightFlags.bit_set(user.rightFlags, User::RightFlags::FORUM_READ)

                if !user_has_read_flag
                    forum = nil
                    status = :unauthorized
                end
            end

            if forum
                forum_has_read_flag = User::RightFlags.bit_set(forum.rightFlags, User::RightFlags::FORUM_READ)

                if !forum_has_read_flag
                    forum = nil
                    status = :unauthorized
                end
            end
        end

        # Regenerate session token
        if user
            user.session = user.generate_token
            user.sessionEnd = now + User::SESSION_EXPIRY_TIME
            user.lastActivityTime = now
            user.save!
            session[:token] = user.session
            session[:expires_at] = user.sessionEnd
        end
        render json: {data: forum}, status: status
    end

    def destroy
        id = params[:id]
        now = Time::now
        token = session[:token]
        status = :ok

        # Check token and find user with it
        if token
            user = User.where("session = ? AND sessionEnd > ?", token, now).first
        end

        # Check user's delete flag
        if user
            has_user_delete_flag = User::RightFlags.bit_set(user.rightFlags, User::RightFlags::FORUM_DELETE)

            if has_user_delete_flag
                begin
                    forum = SubForum.find(id)
                rescue ActiveRecord::RecordNotFound
                    status = :bad_request
                else
                    forum.delete()
                end
            else
                status = :unauthorized
            end
        else
            status = :unauthorized
        end

        # Regenerate session token
        if user
            user.session = user.generate_token
            user.sessionEnd = now + User::SESSION_EXPIRY_TIME
            user.lastActivityTime = now
            user.save!
            session[:token] = user.session
            session[:expires_at] = user.sessionEnd
        end
        render status: status
    end
end
