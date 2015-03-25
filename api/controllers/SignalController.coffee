 # SignalController
 #
 # @description :: Server-side logic for managing instruments
 # @help        :: See http://links.sailsjs.org/docs/controllers

Promise = require "bluebird"

module.exports =

    ema5ema10: (req, res, next) ->
        candles = req.body
        ema5_options =
            url: "http://127.0.0.1:1337/api/instrument/ema5"
            method: "post"
            json: candles
            headers:
                "access-token": req.headers["access-token"]
        ema10_options =
            url: "http://127.0.0.1:1337/api/instrument/ema10"
            method: "post"
            json: candles
            headers:
                "access-token": req.headers["access-token"]

        get_ema5 = oandaRequest ema5_options

        get_ema10 = oandaRequest ema10_options

        compare_ema5ema10 = Promise.method (ema5, ema10) ->
            length = ema5.length
            time = ema5[length - 1].time
            ema5 = ema5.map (d) -> d.value
            ema10 = ema10.map (d) -> d.value
            ema5_upwards = ema5[length - 1] > ema5[length - 2]
            ema10_upwards = ema10[length - 1] > ema10[length - 2]
            ema5_cross_upwards_ema10 = ema5[length - 1] > ema10[length - 1] and ema5[length - 2] < ema10[length - 2]
            ema5_cross_downwards_ema10 = ema5[length - 1] < ema10[length - 1] and ema5[length - 2] > ema10[length - 2]
            buy = ema5_upwards and ema10_upwards and ema5_cross_upwards_ema10
            sell = !ema5_upwards and !ema10_upwards and ema5_cross_downwards_ema10
            if buy
                value = "buy"
            else if sell
                value = "sell"
            else
                value = false
            response =
                time: time
                value: value
            return response

        Promise.join get_ema5, get_ema10, compare_ema5ema10
            .then (response) -> res.json response
            .catch (error) -> next error

    rsi: (req, res, next) ->
        options =
            url: "http://127.0.0.1:1337/api/instrument/rsi"
            json: req.body
            method: "post"
            headers:
                "access-token": req.headers["access-token"]
        oandaRequest options
            .then (json) ->
                length = json.length
                time = json[length - 1].time
                json = json.map (d) -> d.value
                [..., second, first] = json
                upwards = second < first
                buy_values = 50 <= first < 70
                sell_values = 30 <= first < 50
                if upwards and buy_values
                    value = "buy"
                else if !upwards and sell_values
                    value = "sell"
                else
                    value = false
                response =
                    time: time
                    value: value
                res.json response
            .catch (error) -> next error.error

    adr: (req, res, next) ->
        options =
            url: "http://127.0.0.1:1337/api/instrument/adr"
            method: "post"
            json: req.body
            headers:
                "access-token": req.headers["access-token"]
        oandaRequest options
            .then (json) ->
                length = json.length
                time = json[length - 1].time
                json = json.map (d) -> d.value
                [..., first] = json
                response = {
                    time: time
                    value: first > 100
                }
                res.json response
            .catch (error) -> next error.error

    stoch: (req, res, next) ->
        options =
            url: "http://127.0.0.1:1337/api/instrument/stoch"
            method: "post"
            json: req.body
            headers:
                "access-token": req.headers["access-token"]
        oandaRequest options
            .then (json) ->
                length = json.length
                time = json[length - 1].time
                json = json.map (d) -> d.value
                [..., second, first] = json
                upwards = second < first
                range = 20 < first < 80
                if upwards and range
                    value = "buy"
                else if !upwards and range
                    value = "sell"
                else
                    value = false
                response = {
                    time: time
                    value: value
                }
                res.json response
            .catch (error) -> next error.error
