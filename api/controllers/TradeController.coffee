 # TradeController
 #
 # @description :: Server-side logic for managing trades
 # @help        :: See http://links.sailsjs.org/docs/controllers

module.exports = {

    index: (req, res) ->
        options =
            url: "https://#{oandaServer req.user.account_type}/v1/accounts/#{req.user.account_id}/trades"
        oandaHeaders req.user.account_type, req.user.oanda_token, options
        jsonParsingRequest options, (error, response, body) ->
            oandaErrors res, error, response, body
            res.json body.trades

    update: (req, res) ->
        options =
            url: "https://#{oandaServer req.user.account_type}/v1/accounts/#{req.user.account_id}/trades/#{req.body.trade_id}"
        accepted_keys = ["stopLoss", "takeProfit", "trailingStop"]
        options.qs = _.pick req.body, (key) -> key in accepted_keys
        oandaHeaders req.user.account_type, req.user.oanda_token, options
        jsonParsingRequest.patch options, (error, response, body) ->
            oandaErrors res, error, response, body
            res.json body

    delete: (req, res) ->
        options =
            url: "https://#{oandaServer req.user.account_type}/v1/accounts/#{req.user.account_id}/trades/#{req.body.trade_id}"
        oandaHeaders req.user.account_type, req.user.oanda_token, options
        jsonParsingRequest.del options, (error, response, body) ->
            oandaErrors res, error, response, body
            res.json body

}
