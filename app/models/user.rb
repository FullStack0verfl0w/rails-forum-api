class User < ApplicationRecord
    class << self
        def from_omniauth(auth)
            info = auth[:info]
            now = Time::now

            user = find_or_initialize_by(steamID: auth[:uid])
            user.status = true
            user.session = user.generate_token
            user.sessionEnd = now + self::SESSION_EXPIRY_TIME
            user.lastTimeOnline = now
            user.lastActivityTime = now

            if !user.rightFlags
                user.rightFlags = self::RightFlags::FORUM_READ |
                                  self::RightFlags::COMMENTS_READ |
                                  self::RightFlags::COMMENTS_MODIFY |
                                  self::RightFlags::COMMENTS_CREATE |
                                  self::RightFlags::COMMENTS_SELF_DELETE |
                                  self::RightFlags::THREADS_SELF_DELETE |
                                  self::RightFlags::THREADS_READ |
                                  self::RightFlags::THREADS_CREATE |
                                  self::RightFlags::THREADS_MOFIDY
            end

            if !user.karma
                user.karma = 0
            end

            if !user.posts
                user.posts = [].to_json
            end

            user.save!
            return user
        end
    end

    def generate_token
        token = loop do
            random = SecureRandom.base58()
            break random unless User.exists?(session: random)
        end
    end

    SESSION_EXPIRY_TIME = 1800 # seconds or 30 minutes

    module RightFlags
        NONE            = 0

        FORUM_READ      = 1
        FORUM_CREATE    = 2
        FORUM_DELETE    = 4
        FORUM_MODIFY    = 8

        COMMENTS_READ   = 16
        COMMENTS_CREATE = 32
        COMMENTS_DELETE = 64
        COMMENTS_MODIFY = 128 # Only for your comments

        THREADS_READ    = 256
        THREADS_CREATE  = 512
        THREADS_DELETE  = 1024
        THREADS_MOFIDY  = 2048 # Only for your topics

        BANNED          = 4096
        SUPERADMIN      = 8192 # It just replace everything the above (except banned)

        COMMENTS_SELF_DELETE = 16384
        THREADS_SELF_DELETE  = 32768

        CAN_SETUP_RIGHTS     = 65536

        def self.bit_set val, bit
            (val & bit) == bit
        end
    end
end
