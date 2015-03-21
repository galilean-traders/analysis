 # TradeController
 #
 # @description :: Server-side logic for managing trades
 # @help        :: See http://links.sailsjs.org/docs/controllers

request = require "request"

module.exports = {

    index: (req, res) ->
        options =
            url: "https://#{oandaServer req.user.account_type}/v1/#{req.user.account_id}/trades"
        oandaHeaders req.user.account_type, req.user.oanda_token, options
        request options, (error, response, body) ->
            if error?
                sails.log.error error
                res.serverError error
            res.json JSON.parse(body).trades

    update: (req, res) ->
        options =
            url: "https://#{oandaServer req.user.account_type}/v1/#{req.user.account_id}/trades/#{req.body.trade_id}"
        accepted_keys = ["stopLoss", "takeProfit", "trailingStop"]
        options.qs = _.pick req.body, (key) -> key in accepted_keys
        oandaHeaders req.user.account_type, req.user.oanda_token, options
        request.patch options, (error, response, body) ->
            if error?
                sails.log.error error
                res.serverError error
            res.json JSON.parse body

    delete: (req, res) ->
        options =
            url: "https://#{oandaServer req.user.account_type}/v1/#{req.user.account_id}/trades/#{req.body.trade_id}"
        oandaHeaders req.user.account_type, req.user.oanda_token, options
        request.delete options, (error, response, body) ->
            if error?
                sails.log.error error
                res.serverError error
            res.json JSON.parse body

}
