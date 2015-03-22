 # TradeController
 #
 # @description :: Server-side logic for managing orders
 # @help        :: See http://links.sailsjs.org/docs/controllers

request = require "request"

module.exports = {

    create: (req, res) ->
        options =
            url: "https://#{oandaServer req.user.account_type}/v1/accounts/#{req.user.account_id}/orders"
        oandaHeaders req.user.account_type, req.user.oanda_token, options
        adr = req.body.adr
        pip = req.body.pip
        instrument = req.body.instrument
        side = req.body.side
        stoploss = 0.1 * adr
        takeprofit = 0.15 * adr
        trailingstop = 12
        account_balance_request_options =
            url:  "https://#{oandaServer req.user.account_type}/v1/accounts/#{req.user.account_id}"
        oandaHeaders req.user.account_type, req.user.oanda_token, account_balance_request_options
        request account_balance_request_options, (error, response, body) ->
            # get the balance to place an order sized at 2% of the current
            # balance
            if error?
                sails.log.error error
                res.serverError error
            balance = JSON.parse(body).balance
            options.form =
                instrument: instrument
                units: 0.02 * balance
                side: side
                type: "market"
                stopLoss: stoploss
                takeProfit: takeprofit
                trailingStop: trailingstop
            request.post options, (error, response, body) ->
                if error?
                    sails.log.error error
                    res.serverError error
                res.json body

    index: (req, res) ->
        options =
            url: "https://#{oandaServer req.user.account_type}/v1/#{req.user.account_id}/orders"
        oandaHeaders req.user.account_type, req.user.oanda_token, options
        request options, (error, response, body) ->
            if error?
                sails.log.error error
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
        options.qs = _.pick req.body, accepted_keys
        oandaHeaders req.user.account_type, req.user.oanda_token, options
        request.patch options, (error, response, body) ->
            if error?
                sails.log.error error
                res.serverError error
            res.json JSON.parse body

    delete: (req, res) ->
        options =
            url: "https://#{oandaServer req.user.account_type}/v1/#{req.user.account_id}/orders/#{req.body.order_id}"
        oandaHeaders req.user.account_type, req.user.oanda_token, options
        request.delete options, (error, response, body) ->
            if error?
                sails.log.error error
                res.serverError error
            res.json JSON.parse body

}
