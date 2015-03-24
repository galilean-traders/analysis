 # InstrumentController
 #
 # @description :: Server-side logic for managing instruments
 # @help        :: See http://links.sailsjs.org/docs/controllers

padding = 18
RateLimiter = require("limiter").RateLimiter
limiter = new RateLimiter(2, 'second')

module.exports =
    index: (req, res) ->
        options =
            url: "https://#{oandaServer req.user.account_type}/v1/instruments"
            qs:
                accountId: req.user.account_id
                fields: "instrument,displayName,pip,precision,maxTradeUnits,halted"
        oandaHeaders req.user.account_type, req.user.oanda_token, options
        jsonParsingRequest options, (error, response, body) ->
            oandaErrors res, error, response, body
            res.json body.instruments.filter (d) -> d.complete is true


    rawdata: (req, res) ->
        options =
            url: "https://#{oandaServer req.user.account_type}/v1/candles"
            qs:
                instrument: req.param 'name'
                count: req.param 'count'
                granularity: req.param 'granularity'
                candleFormat: 'midpoint'
                dailyAlignment: 0
                alignmentTimezone: "Europe/Zurich"
        oandaHeaders req.user.account_type, req.user.oanda_token, options
        etag = memoryCache.get "etag"
        cached = memoryCache.get "cached"
        if etag and cached
            options.headers["If-None-Match"] = etag.etag
        limiter.removeTokens 1, ->
            jsonParsingRequest options, (error, response, body) ->
                oandaErrors res, error, response, body
                sails.log.debug "status code", response.statusCode
                json = body.candles
                if response.statusCode is 304
                    sails.log.debug "sending cached"
                    res.json cached.cached
                else
                    memoryCache.set "etag", response.headers["etag"]
                    memoryCache.set "cached", json
                    res.json json

    historical: (req, res) ->
        options =
            url: "https://#{oandaServer req.user.account_type}/v1/candles"
            qs:
                instrument: req.param 'name'
                start: req.param 'start'
                end: req.param 'end'
                granularity: req.param 'granularity'
                candleFormat: 'midpoint'
                dailyAlignment: 0
                alignmentTimezone: "Europe/Zurich"
        oandaHeaders req.user.account_type, req.user.oanda_token, options
        jsonParsingRequest options, (error, response, body) ->
            oandaErrors res, error, response, body
            res.json body.candles

    ema5: (req, res) ->
        candles = req.body
        zmq_object =
            fun: "EMA"
            args:
                x: candles.map (d) ->
                    d.closeMid
                n: 5
        zmqUtils.send zmq_object, (data) ->
            sails.log.debug "ema5 answer data: #{data}"
            res.json rUtils.filter_NA(data).map (d) ->
                time: candles[d.index].time
                value: d.value

    ema10: (req, res) ->
        candles = req.body
        zmq_object =
            fun: "EMA"
            args:
                x: candles.map (d) ->
                    d.closeMid
                n: 10
        zmqUtils.send zmq_object, (data) ->
            sails.log.debug "ema10 answer data: #{data}"
            res.json rUtils.filter_NA(data).map (d) ->
                time: candles[d.index].time
                value: d.value

    rsi: (req, res) ->
        candles = req.body
        zmq_object =
            fun: "RSI"
            args:
                price: candles.map (d) ->
                    d.closeMid
                n: 14
        zmqUtils.send zmq_object, (data) ->
            sails.log.debug "rsi answer data: #{data}"
            res.json rUtils.filter_NA(data).map (d) ->
                time: candles[d.index].time
                value: d.value

    stoch: (req, res) ->
        candles = req.body
        zmq_object =
            fun: "stoch.json"
            args:
                data: candles
        zmqUtils.send zmq_object, (data) ->
            output = JSON.parse "#{data}"
            response = [{
                name: "fastK"
                values: output.fastK.map (d, i) ->
                    time: candles[i].time
                    value: d
            },{
                name: "fastD"
                values: output.fastD.map (d, i) ->
                    time: candles[i].time
                    value: d
            },{
                name: "slowD"
                values: output.slowD.map (d, i) ->
                    time: candles[i].time
                    value: d
            }]
            # return only values for which slowD is not NA
            res.json response.map (d) ->
                name: d.name
                values: d.values.filter (e, i) ->
                    response[2].values[i].value isnt "NA"

    adr: (req, res) ->
        candles = req.body.candles
        zmq_object =
            fun: "SMA"
            args:
                x: candles.map (d) ->
                    d.highMid - d.lowMid
                n: 14
        zmqUtils.send zmq_object, (data) ->
            sails.log.debug "adr answer data: #{data}"
            res.json rUtils.filter_NA(data).map (d) ->
                time: candles[d.index].time
                value: d.value / req.body.pip
