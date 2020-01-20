class SubForumController < ApplicationController
    # Subforum section
    def index
        status, data = ApplicationController.check_rights(params, session, UserGroup::RightFlags::FORUM_READ) { |status, params, session|
            data = SubForum.all
            [status, data]
        }
        render json: {data: data}, status: status
    end

    def create
        status, data = ApplicationController.check_rights(params, session, UserGroup::RightFlags::FORUM_CREATE) { |status, params, session|
            name = params[:title] || ""
            desc = params[:desc] || ""
            icon = params[:icon] || SubForum::ICONS[0]
            can_view = params[:canView] || [:all].to_json

            # Check name and description length
            if (name.length < SubForum::TITLE_MIN_LEN && SubForum::TITLE_MIN_LEN != -1) ||
                (name.length > SubForum::TITLE_MAX_LEN && SubForum::TITLE_MAX_LEN != -1) ||
                (desc.length < SubForum::DESC_MIN_LEN && SubForum::DESC_MIN_LEN != -1) ||
                (desc.length > SubForum::DESC_MAX_LEN && SubForum::DESC_MAX_LEN != -1) ||
                !SubForum::ICONS.include?(icon)

                status = :bad_request

            # If everything is alright update record in database
            else
                forum = SubForum.create(
                    name: name,
                    description: desc,
                    icon: icon,
                    canView: can_view
                )
                forum.save!
            end
            [status, nil]
        }
        render status: status
    end

    def update
        status, data = ApplicationController.check_rights(params, session, UserGroup::RightFlags::FORUM_MODIFY) { |status, params, session|
            name = params[:title] || ""
            desc = params[:desc] || ""
            icon = params[:icon] || SubForum::ICONS[0]
            can_view = params[:canView] || [:all].to_json

            # Find existing sub forum
            begin
                forum = SubForum.find params[:id]
            rescue ActiveRecord::RecordNotFound

                # Change status if not found
                status = :not_found
            else

                # Check name and description length
                if (name.length < SubForum::TITLE_MIN_LEN && SubForum::TITLE_MIN_LEN != -1) ||
                    (name.length > SubForum::TITLE_MAX_LEN && SubForum::TITLE_MAX_LEN != -1) ||
                    (desc.length < SubForum::DESC_MIN_LEN && SubForum::DESC_MIN_LEN != -1) ||
                    (desc.length > SubForum::DESC_MAX_LEN && SubForum::DESC_MAX_LEN != -1) ||
                    !SubForum::ICONS.include?(icon)

                    status = :bad_request

                # If everything is alright update record in database
                else
                    forum.name = name
                    forum.description = desc
                    forum.icon = icon
                    forum.canView = can_view
                    forum.save!
                end
            end
            [status, nil]
        }
        render status: status
    end

    def show
        status, data = ApplicationController.check_rights(params, session, UserGroup::RightFlags::FORUM_READ) { |status, params, session|
            begin
                data = SubForum.find params[:id]
            rescue ActiveRecord::RecordNotFound
                status = :not_found
            end
            [status, data]
        }
        render json: {data: data}, status: status
    end

    def destroy
        status, data = ApplicationController.check_rights(params, session, UserGroup::RightFlags::FORUM_DELETE) { |status, params, session|
            begin
                forum = SubForum.find params[:id]
            rescue ActiveRecord::RecordNotFound
                status = :not_found
            else
                forum.delete
            end
            [status, nil]
        }
        render status: status
    end
end
