class ApplicationController < ActionController::API
    def stub
        render status: :ok
    end

    # This will replace 25 lines of code for each API method. ~125 lines for each controller
    def self.check_rights params, session, right_flag, &callback
        data = []
        status = :ok

        # Just find user if token exists
        user = User.find_by "token = ? AND tokenEnd > ?", session[:token], Time::now

        # Check user's delete flag
        group = if user
            UserGroup.find_by name: user.userGroup
        else
            UserGroup.find_by name: UserGroup::DefaultGroups[:guest][:name]
        end

        # Find rightflag in user group
        if group.has_flag right_flag
            status, data = callback.call(status, params, session, user, group)
        else
            # GTFO if we didn't
            status = :unauthorized
        end

        # Regenerate session token
        if user
            user.generate_token session
        end
        [status, data]
    end
end
