 # TradeController
 #
 # @description :: Server-side logic for managing orders
 # @help        :: See http://links.sailsjs.org/docs/controllers

request = require "request"

module.exports = {

    create: (req, res) ->
        options =
            url: "https://#{oandaServer req.user.account_type}/v1/#{req.user.account_id}/orders"
        unless req.user.account_type is "sandbox"
            options.headers =
                authorization: "Bearer #{req.user.oanda_token}"
        adr = req.body.adr
        pip = req.body.pip
        instrument = req.body.instrument
        side = req.body.side
        stoploss = 0.1 * adr
        profittarget = 0.15 * adr
        trailingstop = 12
        request "https://#{oandaServer req.user.account_type}/v1/accounts/#{req.user.account_id}", (error, response, body) ->
            if error?
                console.warn error
                res.serverError error
            balance = JSON.parse(body).balance
            options.qs =
                instrument: instrument
                units: 0.02 * balance
                side: side
                stopLoss: stoploss
                takeProfit: takeprofit
                trailingStop: trailingstop
            request.post options, (error, response, body) ->
                if error?
                    console.warn error
                    res.serverError error
                res.send body

    index: (req, res) ->
        options =
            url: "https://#{oandaServer req.user.account_type}/v1/#{req.user.account_id}/orders"
        unless req.user.account_type is "sandbox"
            options.headers =
                authorization: "Bearer #{req.user.oanda_token}"
        request options, (error, response, body) ->
            if error?
                console.warn error
                res.serverError error
            res.json JSON.parse(body).orders

    update: (req, res) ->
        options =
            url: "https://#{oandaServer req.user.account_type}/v1/#{req.user.account_id}/orders/#{req.body.order_id}"
        accepted_keys = [
            "units"
            "price"
            "expiry"
            "lowerBound"
            "upperBound"
            "stopLoss"
            "takeProfit"
            "trailingStop"
        ]
        options.qs = _.pick req.body, (key) -> key in accepted_keys
        unless req.user.account_type is "sandbox"
            options.headers =
                authorization: "Bearer #{req.user.oanda_token}"
        request.patch options, (error, response, body) ->
            if error?
                console.warn error
                res.serverError error
            res.json JSON.parse body

    delete: (req, res) ->
        options =
            url: "https://#{oandaServer req.user.account_type}/v1/#{req.user.account_id}/orders/#{req.body.order_id}"
        unless req.user.account_type is "sandbox"
            options.headers =
                authorization: "Bearer #{req.user.oanda_token}"
        request.delete options, (error, response, body) ->
            if error?
                console.warn error
                res.serverError error
            res.json JSON.parse body

}
