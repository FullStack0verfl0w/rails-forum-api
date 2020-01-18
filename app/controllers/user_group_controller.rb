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
        group = UserGroup.find_by(name: name)

        user.generate_token session if user

        render json: {data: group}, status: status
    end

    def create
        token = session[:token]
        name = params[:name]
        right_flags = params[:rightFlags].to_i
        status = :ok

        user = User.find_by "token = ? AND tokenEnd > ?", token, Time::now if token
        group = if user
            UserGroup.find_by name: user.userGroup
        else
            UserGroup.find_by name: UserGroup::DefaultGroups[:guest][:name]
        end

        if group.has_flag UserGroup::RightFlags::USERGROUP_CREATE
            if !name.blank? && !UserGroup.exists?(name: name) && right_flags != 0
                user_group = UserGroup.create(
                    name: name,
                    rightFlags: right_flags
                )
                user_group.save!
            else
                status = :bad_request
            end
        else
            status = :unauthorized
        end

        render status: status
    end

    def update
        token = session[:token]
        id = params[:id] # id is actually old name
        name = params[:name]
        right_flags = params[:rightFlags].to_i
        status = :ok

        user = User.find_by "token = ? AND tokenEnd > ?", token, Time::now if token
        group = if user
            UserGroup.find_by name: user.userGroup
        else
            UserGroup.find_by name: UserGroup::DefaultGroups[:guest][:name]
        end

        if group.has_flag UserGroup::RightFlags::USERGROUP_CREATE
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
        else
            status = :unauthorized
        end

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
