# Bootstrap
# (sails.config.bootstrap)
#
# An asynchronous bootstrap function that runs before your Sails app gets lifted.
# This gives you an opportunity to set up your data model, run jobs, or perform some special logic.
#
# For more information on bootstrapping your app, check out:
# http://sailsjs.org/#/documentation/reference/sails.config/sails.config.bootstrap.html

later = require "later"
request = require "request-promise"

module.exports.bootstrap = (cb) ->

    # It's very important to trigger this callback method when you are finished
    # with the bootstrap!  (otherwise your server will never lift, since it's waiting on the bootstrap)

    #scheduled_function = ->
        #User.find()
            #.then (users) ->
                #users.map (user) ->
                    #console.log user
                    #Jwt.findOne({owner: user.id, revoked: false})
                        #.then (token) ->
                            #token = token.token
                            #now = new Date()
                            #names = user.favorites.join()
                            #request {
                                #url: "http://localhost:1337/api/instrument/index"
                                #qs:
                                    #instruments: user.favorites
                                #json: true
                                #headers:
                                    #"access-token": token
                            #}, (error, response, instruments) ->
                                #instruments.filter (d) -> not d.halted
                                    #.map (instrument) ->
                                        #pip = parseFloat instrument.pip
                                        #precision = instrument.precision.length - 2
                                        #name = instrument.instrument
                                        #request {
                                            #url: "http://localhost:1337/api/instrument/rawdata"
                                            #qs:
                                                #name: name
                                                #count: 25
                                                #granularity: "M5"
                                            #json: true
                                            #headers:
                                                #"access-token": token
                                        #}

    #scheduled_function()

    #schedule = later.parse.recur()
        #.every(5).minute()

    #later.setInterval scheduled_function, schedule

    cb()
