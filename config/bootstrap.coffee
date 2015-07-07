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
    
    validateTokenAsync = Promise
        .promisify waterlock.validator.validateToken
        .bind waterlock.validator

    save_attempt = (o) ->
        trade_attempt = 
            user: o.user.id
            instrument: o.instrument
            time: o.signals.ema5ema10.time
            ema5ema10: o.signals.ema5ema10.value
            rsi: o.signals.rsi.value
            stoch: o.signals.stoch.value
            adr: o.signals.adr.value
            status: o.signals.status
        TradeAttempt.create(trade_attempt).then (attempt) ->
            sails.log.debug "recorded attempt", attempt
        return o

    place_order = (o) ->
        signal = o.signals.status
        sails.log.debug "signals are:", signal, "for instrument", o.instrument
        return null if not signal
        options =
            url: "http://localhost:1337/api/order/create"
            method: "post"
            headers:
                "access-token": o.token
            json:
                instrument: o.instrument
                adr: o.current_adr
                pip: o.pip
                precision: o.precision.length - 2
                side: signal
        request(options).then (response) ->
            sails.log.debug response.body

    get_trade_status = (signals) ->
        all_equal = signals.adr.value and signals.ema5ema10.value and signals.ema5ema10.value == signals.rsi.value and signals.rsi.value == signals.stoch.value
        if all_equal
            signals.status = signals.ema5ema10.value
        else
            signals.status = false
        return signals
    
    get_signal = (stat, rawdata, token) ->
        options =
            url: "http://localhost:1337/api/signal/#{stat}"
            method: "post"
            json: rawdata
            headers:
                "access-token": token
        request(options)

    get_m5_stats = (token_and_rawdata) ->
        token = token_and_rawdata.token
        rawdata = token_and_rawdata.rawdata
        Promise.props {
            ema5ema10: get_signal "ema5ema10", rawdata, token
            rsi: get_signal "rsi", rawdata, token
            stoch: get_signal "stoch", rawdata, token
        }

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
                .map (instrument) -> _.merge instrument, token_and_user
            return open_instruments

    get_adr = (token_and_instrument) ->
        token = token_and_instrument.token
        instrument = token_and_instrument.instrument
        options =
            url: "http://localhost:1337/api/instrument/rawdata"
            qs:
                name: instrument
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
                        pip: token_and_instrument.pip
                    headers:
                        "access-token": token
                signal_options =
                    url: "http://localhost:1337/api/signal/adr"
                    method: "post"
                    json:
                        candles: rawdata
                        pip: token_and_instrument.pip
                    headers:
                        "access-token": token
                return Promise.props {
                    current_adr: request(instrument_options).then (d) -> d[d.length - 1].value
                    value: request(signal_options).then (d) -> d.value
                }                                     
                                                          
    get_rawdata = (token_and_instrument) ->
        token = token_and_instrument.token
        instrument = token_and_instrument.instrument
        options =
            url: "http://localhost:1337/api/instrument/rawdata"
            qs:
                name: instrument
                count: 25
                granularity: "M5"
            json: true
            headers:
                "access-token": token
        request options
            .then (rawdata) ->
                _.merge token_and_instrument, {rawdata: rawdata}

    get_token = (user) ->
        Jwt.find({owner: user.id, revoked: false})
            .then (tokens) ->
                ts = tokens.map (d) -> d.token
                Promise
                    .filter ts, (token) ->
                        validateTokenAsync token
                            .then (user) -> true
                            .catch (error) -> false
                    .then (valid) ->
                        {
                            token: valid[0]
                            user: user
                        }

    get_users = ->
        User.find()

    scheduled_function = ->
        get_users().then (users) ->
            Promise
                .map users, get_token
                .map (user) -> 
                    return unless user.token?
                    get_open_instruments user
                        .then (instruments) ->
                            Promise.map instruments, (instrument) -> 
                                Promise.join(
                                    get_adr(instrument),
                                    get_rawdata(instrument).then(get_m5_stats),
                                    (adr, m5_stats) ->
                                        m5_stats.adr = adr
                                        Promise.props _.merge instrument, {signals: get_trade_status m5_stats}
                                )
                                    .then save_attempt
                                    .then place_order

    #scheduled_function()    

    schedule = later.parse.recur()
        .every(5).minute()

    #later.setInterval scheduled_function, schedule

    cb()
