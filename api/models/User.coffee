
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

    afterCreate: (newly_created_user, cb) ->
        # sails one-to-one associations are broken
        # see
        # http://stackoverflow.com/a/27752329
        if newly_created_user.auth?
            Auth.update({id: newly_created_user.auth}, {user: newly_created_user.id})
                .then (auth) ->
                    cb()
        else
            cb()

    beforeUpdate: (values, cb) ->
        # see comment to afterCreate
        updated_auth = {}
        updated_auth.email = values.email if values.email?
        updated_auth.password = values.password if values.password?
        if updated_auth
            delete values.email
            delete values.password
            Auth.update values.auth, updated_auth
                .then (auth) -> cb()
                .catch cb

    beforeDestroy: (values, cb) ->
        # see comment to afterCreate
        User.findOne values
            .then (user) ->
                Auth.destroy user.auth
                    .then (auth) -> cb()
                    .catch cb
            .catch cb
