 # TradeController
 #
 # @description :: Server-side logic for managing trades
 # @help        :: See http://links.sailsjs.org/docs/controllers

module.exports = {

    index: (req, res, next) ->
        options =
            url: "https://#{oandaServer req.user.account_type}/v1/accounts/#{req.user.account_id}/trades"
            qs:
                instrument: req.param "instrument"
        oandaHeaders req.user.account_type, req.user.oanda_token, options
        oandaRequest options
            .then (body) -> res.json body.trades
            .catch (error) -> next error.error

    update: (req, res, next) ->
        options =
            url: "https://#{oandaServer req.user.account_type}/v1/accounts/#{req.user.account_id}/trades/#{req.body.trade_id}"
            method: "patch"
        accepted_keys = ["stopLoss", "takeProfit", "trailingStop"]
        options.qs = _.pick req.body, (key) -> key in accepted_keys
        oandaHeaders req.user.account_type, req.user.oanda_token, options
        oandaRequest options
            .then (body) -> res.json body
            .catch (error) -> next error.error

    delete: (req, res, next) ->
        options =
            url: "https://#{oandaServer req.user.account_type}/v1/accounts/#{req.user.account_id}/trades/#{req.body.trade_id}"
            method: "delete"
        oandaHeaders req.user.account_type, req.user.oanda_token, options
        oandaRequest options
            .then (body) -> res.json body
            .catch (error) -> next error.error

}
