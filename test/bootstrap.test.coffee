Sails = require "sails"
sails = undefined

before (done) ->
    this.timeout 0
    Sails.lift {}, (error, server) ->
        sails = server
        if error?
            return done(error)
        done(error, sails)

after (done) ->
    sails.lower(done)
