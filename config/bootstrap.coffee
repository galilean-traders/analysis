# Bootstrap
# (sails.config.bootstrap)
#
# An asynchronous bootstrap function that runs before your Sails app gets lifted.
# This gives you an opportunity to set up your data model, run jobs, or perform some special logic.
#
# For more information on bootstrapping your app, check out:
# http://sailsjs.org/#/documentation/reference/sails.config/sails.config.bootstrap.html

later = require "later"

module.exports.bootstrap = (cb) ->

    # It's very important to trigger this callback method when you are finished
    # with the bootstrap!  (otherwise your server will never lift, since it's waiting on the bootstrap)

    scheduled_function = ->
        console.log "scheduled_function?"
        User.find()
            .then (users) ->
                console.log users
                users.map (user) ->
                    Jwt.findOne({owner: user.id, revoked: false})
                        .then (token) ->
                            console.log "token", token
                            now = new Date()
                            sails.log.debug now, "found user with token", token

    schedule = later.parse.recur()
        .every(5).minute()

    later.setInterval scheduled_function, schedule

    cb()
