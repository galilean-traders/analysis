Sails = require "sails"
sails = undefined

before (done) ->
    this.timeout 0
    Sails.lift {log: {level: "error"}}, (error, server) ->
        sails = server
        if error?
            return done(error)
        done(error, sails)

after (done) ->
    sails.lower(done)
