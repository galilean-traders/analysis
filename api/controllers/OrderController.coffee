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
        precision = req.body.precision
        instrument = req.body.instrument
        side = req.body.side
        stoploss = 0.1 * adr * pip
        takeprofit = 0.15 * adr * pip
        trailingstop = 12
        
        # get the current price and trade status
        current_price_request_options =
            url:  "https://#{oandaServer req.user.account_type}/v1/prices"
            qs:
                instruments: instrument
        oandaHeaders req.user.account_type, req.user.oanda_token, current_price_request_options
        get_current_price = (error, response, body) ->
            if error?
                sails.log.error error
                res.serverError error
            prices = JSON.parse(body).prices[0]
            if "status" in prices
                # the presence of this parameter means that trading is
                # halted, see:
                # http://developer.oanda.com/rest-live/rates/#getCurrentPrices
                res.serverError "trading for #{instrument} is now halted on oanda.com"
            if side is "buy"
                stoploss = prices.bid - stoploss
                takeprofit = prices.ask + takeprofit
            else if side is "sell"
                stoploss = prices.ask + stoploss
                takeprofit = prices.bid - takeprofit
            else
                res.serverError "#{side} MUST be either buy or sell"

            # get the current account balance in order to place an order sized
            # at 2% of the current balance
            account_balance_request_options =
                url:  "https://#{oandaServer req.user.account_type}/v1/accounts/#{req.user.account_id}"
            oandaHeaders req.user.account_type, req.user.oanda_token, account_balance_request_options
            get_account_balance = (error, response, body) ->
                if error?
                    sails.log.error error
                    res.serverError error
                balance = JSON.parse(body).balance
                options.form =
                    instrument: instrument
                    units: (0.02 * balance).toFixed(0)
                    side: side
                    type: "market"
                    stopLoss: stoploss.toFixed precision
                    takeProfit: takeprofit.toFixed precision
                    trailingStop: trailingstop

                # send the order creation request to oanda and forward the response
                forward_order = (error, response, body) ->
                    if error?
                        sails.log.error error
                        res.serverError error
                    res.json body
                request.post options, forward_order

            request account_balance_request_options, get_account_balance

        request current_price_request_options, get_current_price

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
