Sails = require "sails"
sails = undefined
chai = require "chai"
chai.should()

before (done) ->
    this.timeout 0
    Sails.lift {}, (error, server) ->
        sails = server
        if error?
            return done(error)
        User.create({
            name: "ciccio"
        })
        done(error, sails)

after (done) ->
    sails.lower(done)
