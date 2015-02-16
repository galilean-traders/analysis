 # SignalController
 #
 # @description :: Server-side logic for managing instruments
 # @help        :: See http://links.sailsjs.org/docs/controllers

request = require "request"

module.exports =

    ema5ema10: (req, res) ->
        candles = req.body
        ema5_options =
            url: "http://127.0.0.1:1337/api/instrument/ema5"
            body: candles
            json: true
            headers:
                "access-token": req.headers["access-token"]
        ema10_options =
            url: "http://127.0.0.1:1337/api/instrument/ema10"
            body: candles
            json: true
            headers:
                "access-token": req.headers["access-token"]
        request.post ema5_options, (error, response, ema5) ->
            if error?
                console.warn error
                res.serverError error
            request.post ema10_options, (error, response, ema10) ->
                if error?
                    console.warn error
                    res.serverError error
                length = ema5.length
                time = ema5[length - 1].time
                ema5 = ema5.map (d) -> d.value
                ema10 = ema10.map (d) -> d.value
                ema5_upwards = ema5[length - 1] > ema5[length - 2]
                ema10_upwards = ema10[length - 1] > ema10[length - 2]
                ema5_cross_upwards_ema10 = ema5[length - 1] > ema10[length - 1] and ema5[length - 2] < ema10[length - 2]
                ema5_cross_downwards_ema10 = ema5[length - 1] < ema10[length - 1] and ema5[length - 2] > ema10[length - 2]
                long = ema5_upwards and ema10_upwards and ema5_cross_upwards_ema10
                short = !ema5_upwards and !ema10_upwards and ema5_cross_downwards_ema10
                if long
                    value = "long"
                else if short
                    value = "short"
                else
                    value = false
                response =
                    time: time
                    value: value
                console.log "response is", response
                res.json response

    rsi: (req, res) ->
        candles = req.body
        options =
            url: "http://127.0.0.1:1337/api/instrument/rsi"
            body: candles
            json: true
            headers:
                "access-token": req.headers["access-token"]
        request.post options, (error, response, json) ->
            if error?
                console.warn error
                res.serverError error
            length = json.length
            time = json[length - 1].time
            json = json.map (d) -> d.value
            [..., second, first] = json
            upwards = second < first
            long_values = 50 <= first < 70
            short_values = 30 <= first < 50
            if upwards and long_values
                value = "long"
            else if !upwards and short_values
                value = "short"
            else
                value = false
            response =
                time: time
                value: value
            res.json response

    adr: (req, res) ->
        options =
            url: "http://127.0.0.1:1337/api/instrument/adr"
            body: req.body
            json: true
            headers:
                "access-token": req.headers["access-token"]
        request.post options, (error, response, json) ->
            length = json.length
            time = json[length - 1].time
            json = json.map (d) -> d.value
            [..., first] = json
            response = {
                time: time
                value: first > 100
            }
            res.json response

    stoch: (req, res) ->
        candles = req.body
        options =
            url: "http://127.0.0.1:1337/api/instrument/stoch"
            body: candles
            json: true
            headers:
                "access-token": req.headers["access-token"]
        request.post options, (error, response, json) ->
            length = json.length
            time = json[length - 1].time
            json = json.map (d) -> d.value
            [..., second, first] = json
            upwards = second < first
            range = 20 < first < 80
            if upwards and range
                value = "long"
            else if !upwards and range
                value = "short"
            else
                value = false
            response = {
                time: time
                value: value
            }
            res.json response
