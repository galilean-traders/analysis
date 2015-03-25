 # AccountController
 #
 # @description :: Server-side logic for managing accounts
 # @help        :: See http://links.sailsjs.org/docs/controllers

RateLimiter = require("limiter").RateLimiter
limiter = new RateLimiter(2, 'second')

module.exports = 
    index: (req, res, next) ->
        #'GET /v1/accounts'
        # http://developer.oanda.com/rest-live/accounts/#getAccountsForUser
        options =
            url: "https://#{oandaServer req.user.account_type}/v1/accounts"
        oandaHeaders req.user.account_type, req.user.oanda_token, options
        limiter.removeTokens 1, ->
            oandaRequest options
                .then (body) -> res.json body.accounts
                .catch (error) -> next error.error

    findOne: (req, res, next) ->
        options:
            url: "https://#{oandaServer req.user.account_type}/v1/accounts"
            qs:
                account_id: req.account_id
        oandaHeaders req.user.account_type, req.user.oanda_token, options
        limiter.removeTokens 1, ->
            oandaRequest options
                .then (body) -> res.json body
                .catch error -> next error.error
