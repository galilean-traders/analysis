 # SignalController
 #
 # @description :: Server-side logic for managing instruments
 # @help        :: See http://links.sailsjs.org/docs/controllers

module.exports =

    ema5ema10: (req, res) ->
        candles = req.body
        ema5_options =
            url: "http://127.0.0.1:1337/api/instrument/ema5"
            json: candles
            headers:
                "access-token": req.headers["access-token"]
        ema10_options =
            url: "http://127.0.0.1:1337/api/instrument/ema10"
            json: candles
            headers:
                "access-token": req.headers["access-token"]
        jsonParsingRequest.post ema5_options, (error, response, ema5) ->
            oandaErrors res, error, response, ema5
            jsonParsingRequest.post ema10_options, (error, response, ema10) ->
                oandaErrors res, error, response, ema10
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
                sails.log.debug "response is", response
                res.json response

    rsi: (req, res) ->
        candles = req.body
        options =
            url: "http://127.0.0.1:1337/api/instrument/rsi"
            json: candles
            headers:
                "access-token": req.headers["access-token"]
        jsonParsingRequest.post options, (error, response, json) ->
            oandaErrors res, error, response, json
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

    adr: (req, res) ->
        options =
            url: "http://127.0.0.1:1337/api/instrument/adr"
            json: req.body
            headers:
                "access-token": req.headers["access-token"]
        jsonParsingRequest.post options, (error, response, json) ->
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
            json: candles
            headers:
                "access-token": req.headers["access-token"]
        jsonParsingRequest.post options, (error, response, json) ->
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
