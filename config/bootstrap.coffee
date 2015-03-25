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

    get_m5_stats = (token, rawdata) ->
        ["ema5ema10", "rsi", "stoch"].map (stat) ->
            options =
                url: "http://localhost:1337/api/signal/#{stat}"
                method: "post"
                json: rawdata
                headers:
                    "access-token": token
            request options

    get_open_instruments = (token, user) ->
        options =
            url: "http://localhost:1337/api/instrument/index"
            qs:
                instruments: user.favorites
            json: true
            headers:
                "access-token": token
        request options
            .then (instruments) ->
                return instruments.filter (instrument) ->
                    not instrument.halted

    get_adr = (token, instrument) ->
        options =
            url: "http://localhost:1337/api/instrument/rawdata"
            qs:
                name: instrument.instrument
                count: 25
                granularity: "D"
            json: true
            headers:
                "access-token": token
        request(options).then (rawdata) ->
            instrument_options =
                url: "http://localhost:1337/api/instrument/adr"
                method: "post"
                json:
                    candles: rawdata
                    pip: instrument.pip
                headers:
                    "access-token": token
            signal_options =
                url: "http://localhost:1337/api/signal/adr"
                method: "post"
                json:
                    candles: rawdata
                    pip: instrument.pip
                headers:
                    "access-token": token
            return [request(instrument_options).get(24), request(signal_options)]

    get_rawdata = (token, instrument) ->
        options =
            url: "http://localhost:1337/api/instrument/rawdata"
            qs:
                name: instrument.instrument
                count: 25
                granularity: "M5"
            json: true
            headers:
                "access-token": token
        request option

    get_token = (user) ->
        Jwt.findOne({owner: user.id, revoked: false})
            .then (token) -> token.token

    get_users = User.find().then (users) ->
        users.map get_token

    #scheduled_function()

    #schedule = later.parse.recur()
        #.every(5).minute()

    #later.setInterval scheduled_function, schedule

    cb()
