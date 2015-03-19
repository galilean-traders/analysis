 # TradeController
 #
 # @description :: Server-side logic for managing trades
 # @help        :: See http://links.sailsjs.org/docs/controllers

request = require "request"

module.exports = {

    index: (req, res) ->
        options =
            url: "https://#{oandaServer req.user.account_type}/v1/#{req.user.account_id}/trades"
        unless req.user.account_type is "sandbox"
            options.headers =
                authorization: "Bearer #{req.user.oanda_token}"
        request options, (error, response, body) ->
            if error?
                console.warn error
                res.serverError error
            res.json JSON.parse(body).trades

    update: (req, res) ->
        options =
            url: "https://#{oandaServer req.user.account_type}/v1/#{req.user.account_id}/trades/#{req.body.trade_id}"
        accepted_keys = ["stopLoss", "takeProfit", "trailingStop"]
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
            url: "https://#{oandaServer req.user.account_type}/v1/#{req.user.account_id}/trades/#{req.body.trade_id}"
        unless req.user.account_type is "sandbox"
            options.headers =
                authorization: "Bearer #{req.user.oanda_token}"
        request.delete options, (error, response, body) ->
            if error?
                console.warn error
                res.serverError error
            res.json JSON.parse body

}
