 # AccountController
 #
 # @description :: Server-side logic for managing accounts
 # @help        :: See http://links.sailsjs.org/docs/controllers

request = require "request"

module.exports = 
    index: (req, res) ->
        #'GET /v1/accounts'
        # http://developer.oanda.com/rest-live/accounts/#getAccountsForUser
        options:
            url: "https://#{oandaServer req.user.account_type}/v1/accounts"
        unless req.user.account_type is "sandbox"
            options.headers =
                    authorization: "Bearer #{req.user.oanda_token}"
        request options, (error, response, body) ->
            if error?
                console.warn error
                res.serverError error
            res.json body

    findOne: (req, res) ->
        options:
            url: "https://#{oandaServer req.user.account_type}/v1/accounts"
            qs:
                account_id: req.account_id
        unless req.user.account_type is "sandbox"
            options.headers =
                    authorization: "Bearer #{req.user.oanda_token}"
        request options, (error, response, body) ->
            if error?
                console.warn error
                res.serverError error
            res.json body
