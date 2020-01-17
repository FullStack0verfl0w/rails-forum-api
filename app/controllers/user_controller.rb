class UserController < ApplicationController
    def create
        begin
            @user = User.from_omniauth request.env['omniauth.auth'], session
        rescue Exception => e
            puts e.message
        end
        redirect_to root_path
    end

    def destroy_session
        now = Time::now

        begin
            if session[:token]
                user = User.where("session = ? AND sessionEnd > ?", session[:token], now).first

                if user
                    user.sessionEnd = now
                    user.online = false
                    user.lastTimeOnline = now
                    user.lastActivityTime = now
                end
            end

            # Reset session for client
            session[:token] = nil
            session[:expires_at] = nil
        rescue
            status = :internal_server_error
        else
            status = :ok
        end

        render status: status
    end
end
