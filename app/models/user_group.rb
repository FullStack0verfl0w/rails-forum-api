class UserGroup < ApplicationRecord
    def self.has_flag user_group, flag
        begin
            group = UserGroup.where(name: user_group).first
        rescue ActiveRecord::RecordNotFound
            return false
        else
            return (group.rightFlags & flag) == flag
        end
    end

    def has_flag flag
        return (self.rightFlags & flag) == flag
    end

    module RightFlags
        NONE                = 0

        FORUM_CREATE        = 1       # Can user create sub forums
        FORUM_READ          = 2       # Can user read data about sub forums and their threads
        FORUM_MODIFY        = 4       # Can user modify sub forums
        FORUM_DELETE        = 8       # Can user delete sub forums

        THREAD_CREATE       = 16      # Can user create threads
        THREAD_READ         = 32      # Can user read threads and their comments
        THREAD_MODIFY       = 64      # Can user modify their own threads
        THREAD_DELETE       = 128     # Can user delete threads
        THREAD_DELETE_OWN   = 256     # Can user delete their own threads

        COMMENT_CREATE      = 512     # Can user create comments
        COMMENT_READ        = 1024    # Can user read comments
        COMMENT_MODIFY      = 2048    # Can user modify their own comments
        COMMENT_DELETE      = 4096    # Can user delete comments
        COMMENT_DELETE_OWN  = 8192    # Can user delete their own comments

        USER_CAN_BAN        = 16384   # Can user ban another user or not
        USER_CANT_BE_BANNED = 32768   # For super admins

        USERGROUP_CREATE    = 65536   # Can user create user groups
        USERGROUP_MODIFY    = 131072  # Can user modify user groups
        USERGROUP_DELETE    = 262144  # Can user delete user groups
        USERGROUP_CHANGE    = 524288  # Can user change user group of another user
    end

    DefaultGroups = {

        # Template for guest group
        # Using for unauthorized clients
        guest: {
            name: "guest",
            rightFlags: UserGroup::RightFlags::FORUM_READ |
                        UserGroup::RightFlags::THREAD_READ |
                        UserGroup::RightFlags::COMMENT_READ
        },

        # Template for user group
        # Using for authorized clients
        user: {
            name: "user",
            rightFlags: UserGroup::RightFlags::FORUM_READ |

                        UserGroup::RightFlags::THREAD_CREATE |
                        UserGroup::RightFlags::THREAD_READ |
                        UserGroup::RightFlags::THREAD_MODIFY |
                        UserGroup::RightFlags::THREAD_DELETE_OWN |

                        UserGroup::RightFlags::COMMENT_CREATE |
                        UserGroup::RightFlags::COMMENT_READ |
                        UserGroup::RightFlags::COMMENT_MODIFY |
                        UserGroup::RightFlags::COMMENT_DELETE_OWN
        },

        # Template for super admin group
        # Have all rights and cannot be banned
        superadmin: {
            name: "superadmin",
            rightFlags: UserGroup::RightFlags::FORUM_CREATE |
                        UserGroup::RightFlags::FORUM_READ |
                        UserGroup::RightFlags::FORUM_MODIFY |
                        UserGroup::RightFlags::FORUM_DELETE |

                        UserGroup::RightFlags::THREAD_CREATE |
                        UserGroup::RightFlags::THREAD_READ |
                        UserGroup::RightFlags::THREAD_MODIFY |
                        UserGroup::RightFlags::THREAD_DELETE |
                        UserGroup::RightFlags::THREAD_DELETE_OWN |

                        UserGroup::RightFlags::COMMENT_CREATE |
                        UserGroup::RightFlags::COMMENT_READ |
                        UserGroup::RightFlags::COMMENT_MODIFY |
                        UserGroup::RightFlags::COMMENT_DELETE |
                        UserGroup::RightFlags::COMMENT_DELETE_OWN |

                        UserGroup::RightFlags::USER_CAN_BAN |
                        UserGroup::RightFlags::USER_CANT_BE_BANNED |

                        UserGroup::RightFlags::USERGROUP_CREATE |
                        UserGroup::RightFlags::USERGROUP_MODIFY |
                        UserGroup::RightFlags::USERGROUP_DELETE |
                        UserGroup::RightFlags::USERGROUP_CHANGE
        },
    }
end
