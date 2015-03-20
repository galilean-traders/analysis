
#User

#@module      :: Model
#@description :: This is the base user model
#@docs        :: http://waterlock.ninja/documentation

waterlock = require "waterlock"

module.exports =
    attributes: waterlock.models.user.attributes(
        oanda_token: 
            type: "string"
            required: "true"
        account_type:
            type: "string"
            required: "true"
        account_id:
            type: "string"
            required: "true"
        favorites: "array"
    )

    beforeCreate: waterlock.models.user.beforeCreate
    beforeUpdate: waterlock.models.user.beforeUpdate
    
    afterCreate: (newly_created_user, cb) ->
        # sails one-to-one associations are broken
        # see
        # http://stackoverflow.com/a/27752329
        if newly_created_user.auth?
            Auth.update {id: newly_created_user.auth}, {user: newly_created_user.id}
                .exec cb
        else
            cb()

    beforeDestroy: (values, cb) ->
        User.findOne values
            .exec (error, user) ->
                if error?
                    cb error
                Auth.destroy user.auth
                    .exec (error, auth) ->
                        if error?
                            cb error
                        else
                            cb()
