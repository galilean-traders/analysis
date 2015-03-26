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
Promise = require "bluebird"

module.exports.bootstrap = (cb) ->

    # It's very important to trigger this callback method when you are finished
    # with the bootstrap!  (otherwise your server will never lift, since it's waiting on the bootstrap)
    
    place_order = (token_instrument_adr_signal) ->
        signal = token_instrument_adr_signal.signal
        sails.log.debug "signals are:", signal, "for instrument", token_instrument_adr_signal.instrument.instrument
        return null if not signal
        token = token_instrument_adr_signal.token
        instrument = token_instrument_adr_signal.instrument
        adr = token_instrument_adr_signal.adr
        options =
            url: "http://localhost:1337/api/order/create"
            method: "post"
            headers:
                "access-token": token
            json:
                instrument: instrument.instrument
                adr: adr
                pip: instrument.pip
                precision: instrument.precision.length - 2
                side: signal
        request(options).then (response) ->
            sails.log.debug response.body

    get_trade_status = (signals) ->
        all_equal = signals.reduce (a, b) -> if a == b then a else false
        if all_equal and signals[0]
            return signals[0]
        else
            return false
    
    get_m5_stats = (token_and_rawdata) ->
        token = token_and_rawdata.token
        rawdata = token_and_rawdata.rawdata
        ["ema5ema10", "rsi", "stoch"].map (stat) ->
            options =
                url: "http://localhost:1337/api/signal/#{stat}"
                method: "post"
                json: rawdata
                headers:
                    "access-token": token
            request(options).then (signal) -> signal.value

    get_open_instruments = (token_and_user) ->
        token = token_and_user.token
        user = token_and_user.user
        options =
            url: "http://localhost:1337/api/instrument/index"
            qs:
                instruments: user.favorites
            json: true
            headers:
                "access-token": token
        request(options).then (instruments) ->
            open_instruments = instruments
                .filter (instrument) -> not instrument.halted
                .map (instrument) -> 
                    token: token
                    user: user
                    instrument: instrument
            return open_instruments

    get_adr = (token_and_instrument) ->
        token = token_and_instrument.token
        instrument = token_and_instrument.instrument
        options =
            url: "http://localhost:1337/api/instrument/rawdata"
            qs:
                name: instrument.instrument
                count: 25
                granularity: "D"
            json: true
            headers:
                "access-token": token
        return request(options)
            .then (rawdata) ->
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
                return Promise.props {
                    value: request(instrument_options).then (d) -> d[10].value
                    signal: request(signal_options).then (d) -> d.value
                }                                     
            .then (adr) ->
                return _.merge token_and_instrument, adr
                                                          
    get_rawdata = (token_and_instrument) ->
        token = token_and_instrument.token
        instrument = token_and_instrument.instrument
        options =
            url: "http://localhost:1337/api/instrument/rawdata"
            qs:
                name: instrument.instrument
                count: 25
                granularity: "M5"
            json: true
            headers:
                "access-token": token
        request options
            .then (rawdata) ->
                _.merge token_and_instrument, {rawdata: rawdata}

    get_token = (user) ->
        Jwt.findOne({owner: user.id, revoked: false})
            .then (token) -> {
                token: token.token
                user: user
            }

    get_users = ->
        User.find()

    scheduled_function = ->
        get_users().then (users) ->
            Promise
                .map users, get_token
                .map (user) -> 
                    get_open_instruments user
                        .then (instruments) ->
                            Promise.map instruments, (instrument) -> 
                                Promise.join(
                                    get_adr(instrument),
                                    get_rawdata(instrument).then(get_m5_stats),
                                    (adr, m5_stats) ->
                                        object = Promise.props {
                                            adr: adr.value
                                            signals: get_trade_status [adr.signal].concat m5_stats
                                        })
                                    .then (signal) ->
                                        instrument.signal = signal.signals
                                        instrument.adr = signal.adr
                                        place_order instrument

    scheduled_function()    

    schedule = later.parse.recur()
        .every(5).minute()

    later.setInterval scheduled_function, schedule

    cb()
