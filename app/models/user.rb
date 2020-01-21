class User < ApplicationRecord
    def self.from_omniauth auth, session
        info = auth[:info]
        info_json = auth[:extra][:raw_info].to_json
        now = Time::now

        user = find_or_initialize_by steamID: auth[:uid]
        user.status = true
        user.generate_token session
        user.lastTimeOnline = now

        # Set user group if it's not set
        if !user.userGroup
            user.userGroup = "user"
        else
            # Reset user group if client's group doesn't exist
            begin
                group = UserGroup.find_by name: user.userGroup
            rescue
                user.userGroup = "user"
            end
        end

        if !user.steamData
            user.steamData = info_json
        else
            if user.steamData != info_json
                user.steamData = info_json
            end
        end

        user.save!
        return user
    end

    # Generates new token and saves it to session and server database
    def generate_token session
        now = Time::now

        # Generate our token
        token = loop do
            random = SecureRandom.base58()
            break random unless User.exists? token: random
        end

        self.token = token
        self.tokenEnd = now + User::TOKEN_EXPIRY_TIME
        self.lastActivityTime = now
        self.save!

        session[:token] = self.token
        session[:expires_at] = self.tokenEnd
    end

    TOKEN_EXPIRY_TIME = 1800 # seconds or 30 minutes
end
