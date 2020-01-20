class UserGroupController < ApplicationController
    def index
        token = session[:token]
        status = :ok

        user = User.find_by "token = ? AND tokenEnd > ?", token, Time::now if token
        groups = UserGroup.all

        user.generate_token session if user

        render json: {data: groups}, status: status
    end

    def show
        name = params[:id]
        token = session[:token]
        status = :ok

        user = User.find_by "token = ? AND tokenEnd > ?", token, Time::now if token
        begin
            group = UserGroup.find_by! name: name
        rescue ActiveRecord::RecordNotFound
            status = :not_found
        end

        user.generate_token session if user

        render json: {data: group}, status: status
    end

    def create
        status, data = ApplicationController.check_rights(params, session, UserGroup::RightFlags::USERGROUP_CREATE) { |status, params, session|
            name = params[:name]
            right_flags = params[:rightFlags].to_i
            puts "right flags #{right_flags}"

            if !name.blank? && !UserGroup.exists?(name: name) && right_flags != 0
                user_group = UserGroup.create(
                    name: name,
                    rightFlags: right_flags
                )
                user_group.save!
            else
                status = :bad_request
            end
            [status, data]
        }
        render status: status
    end

    def update
        status, data = ApplicationController.check_rights(params, session, UserGroup::RightFlags::USERGROUP_MODIFY) { |status, params, session|
            id = params[:id]
            name = params[:name]
            right_flags = params[:rightFlags]
            if !name.blank? && !id.blank? && right_flags != 0
                begin
                    user_group = UserGroup.find_by! name: id
                    user_group.name = name
                    user_group.rightFlags = right_flags
                    user_group.save!
                rescue ActiveRecord::RecordNotFound
                    status = :not_found
                end
            else
                status = :bad_request
            end
            [status, data]
        }
        render status: status
    end

    def configure
        token = session[:token]
        status = :ok

        if token
            user = User.find_by "token = ? AND tokenEnd > ?", token, Time::now

            if user
                groups = UserGroup.all

                if groups.empty?
                    UserGroup::DefaultGroups.each do |name, group_hash|
                        group = UserGroup.create(
                            name: group_hash[:name],
                            rightFlags: group_hash[:rightFlags]
                        )
                    end
                else
                    status = :bad_request
                end
            else
                status = :unauthorized
            end
        else
            status = :unauthorized
        end
        render status: status
    end
end
