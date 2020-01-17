class UserGroupController < ApplicationController
    def configure
        token = session[:token]
        status = :ok

        if token
            user = User.where("token = ? AND tokenEnd > ?", token, Time::now).first

            if user
                groups = UserGroup.all

                if groups.length <= 0
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