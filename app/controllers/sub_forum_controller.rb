class SubForumController < ApplicationController
    def index
        token = session[:token]
        status = :ok

        # Check token and find user with it
        if token
            user = User.find_by "token = ? AND tokenEnd > ?", token, Time::now
        end

        # Get all records from database
        data = SubForum.all

        # Find client's user group
        if user
            group = UserGroup.find_by name: user.userGroup
        else
            group = UserGroup.find_by name: UserGroup::DefaultGroups[:guest][:name]
        end

        # If that user group has no flag to read we make data array empty
        if !group.has_flag UserGroup::RightFlags::FORUM_READ
            data = []
        end

        # Regenerate session token
        if user
            user.generate_token session
        end
        render json: {data: data}, status: status
    end

    def create
        token = session[:token]
        status = :ok

        if token
            user = User.find_by "token = ? AND tokenEnd > ?", token, Time::now

            if user
                group = UserGroup.find_by name: user.userGroup
            else
                group = UserGroup.find_by name: UserGroup::DefaultGroups[:guest][:name]
            end

            if group.has_flag UserGroup::RightFlags::FORUM_CREATE
                name = params[:title] || ""
                desc = params[:desc] || ""
                icon = params[:icon] || SubForum::ICONS[0]
                can_view = params[:canView] || [:all].to_json

                # Check name and description length
                if  (name.length < SubForum::TITLE_MIN_LEN && SubForum::TITLE_MIN_LEN != -1) ||
                    (name.length > SubForum::TITLE_MAX_LEN && SubForum::TITLE_MAX_LEN != -1) ||
                    (desc.length < SubForum::DESC_MIN_LEN && SubForum::DESC_MIN_LEN != -1) ||
                    (desc.length > SubForum::DESC_MAX_LEN && SubForum::DESC_MAX_LEN != -1)

                    status = :bad_request

                # If everything is alright create record in database
                else
                    forum = SubForum.create(
                        name: name,
                        description: desc,
                        icon: icon,
                        canView: can_view,
                        posts: [].to_json
                    )
                    forum.save!
                end

                # Regenerate session token
                if user
                    user.generate_token session
                end
            else
                status = :unauthorized
            end
        else
            status = :unauthorized
        end
        render status: status
    end

    def update
        id = params[:id]
        token = session[:token]
        status = :ok

        if token
            user = User.find_by "token = ? AND tokenEnd > ?", token, Time::now

            if user
                group = UserGroup.find_by name: user.userGroup
            else
                group = UserGroup.find_by name: UserGroup::DefaultGroups[:guest][:name]
            end

            if group.has_flag UserGroup::RightFlags::FORUM_MODIFY
                name = params[:title] || ""
                desc = params[:desc] || ""
                icon = params[:icon] || SubForum::ICONS[0]
                can_view = params[:canView] || [:all].to_json

                # Find existing sub forum
                forum = SubForum.find_by id: id

                if forum
                    # Check name and description length
                    if (name.length < SubForum::TITLE_MIN_LEN && SubForum::TITLE_MIN_LEN != -1) ||
                        (name.length > SubForum::TITLE_MAX_LEN && SubForum::TITLE_MAX_LEN != -1) ||
                        (desc.length < SubForum::DESC_MIN_LEN && SubForum::DESC_MIN_LEN != -1) ||
                        (desc.length > SubForum::DESC_MAX_LEN && SubForum::DESC_MAX_LEN != -1)

                        status = :bad_request

                    # If everything is alright update record in database
                    else
                        forum.name = name
                        forum.description = desc
                        forum.icon = icon
                        forum.canView = can_view
                        forum.save!
                    end
                else
                    status = :not_found
                end

                # Regenerate session token
                if user
                    user.generate_token session
                end
            else
                status = :unauthorized
            end
        else
            status = :unauthorized
        end
        render status: status
    end

    def show
        id = params[:id]
        token = session[:token]
        status = :ok

        # Check token and find user with it
        if token
            user = User.find_by "token = ? AND tokenEnd > ?", token, Time::now
        end

        begin
            # Get client's user group
            if user
                group = UserGroup.find_by name: user.userGroup
            else
                group = UserGroup.find_by name: UserGroup::DefaultGroups[:guest][:name]
            end

            # Check user group flag for read
            if group.has_flag UserGroup::RightFlags::FORUM_READ
                forum = SubForum.find id
            else
                status = :unauthorized
            end

        # Tell client we have not found a record
        rescue ActiveRecord::RecordNotFound
            status = :not_found
        end

        # Regenerate session token
        if user
            user.generate_token session
        end
        render json: {data: forum}, status: status
    end

    def destroy
        id = params[:id]
        token = session[:token]
        status = :ok

        # Check token and find user with it
        if token
            user = User.find_by "token = ? AND tokenEnd > ?", token, Time::now
        end

        # Check user's delete flag
        if user
            group = UserGroup.find_by name: user.userGroup
        else
            group = UserGroup.find_by name: UserGroup::DefaultGroups[:guest][:name]
        end

        if group.has_flag UserGroup::RightFlags::FORUM_DELETE
            begin
                forum = SubForum.find id
            rescue ActiveRecord::RecordNotFound
                status = :not_found
            else
                forum.delete
            end
        else
            status = :unauthorized
        end

        # Regenerate session token
        if user
            user.generate_token session
        end
        render status: status
    end
end
