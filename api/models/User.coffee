
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

    beforeCreate: (params, cb) ->
        Auth.create {
            email: params.email
            password: params.password
        }
            .exec (error, auth) ->
                if error?
                    console.error error
                    return cb error
                else
                    delete params.email
                    delete params.password
                    params.auth = auth.id
                    cb()

    afterCreate: (newly_created_user, cb) ->
        Auth.findOne newly_created_user.auth
            .exec (error, auth) ->
                if error?
                    console.error error
                    return cb error
                waterlock.engine.attachAuthToUser auth, newly_created_user, (error, ua) ->
                    if error?
                        console.error error
                        return cb error
                    cb()

    beforeUpdate: waterlock.models.user.beforeUpdate
