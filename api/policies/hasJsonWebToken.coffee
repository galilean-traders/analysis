'use strict'
#hasJsonWebToken

#@module      :: Policy
#@description :: Assumes that your request has an jwt;

#@docs        :: http://waterlock.ninja/documentation

module.exports = (req, res, next) ->
    req.headers['access_token'] = req.headers['access-token']
    # copy headers as in:
    # https://github.com/waterlock/waterlock/issues/43
    req.user = {}
    waterlock.validator.validateTokenRequest req, (err, user) ->
        if err?
            sails.log.error "authentication error", err
            return res.forbidden err
        Auth.findOne user.auth
            .then (auth) ->
                # valid request, save user to the request
                req.user = user
                req.user.email = auth.email
                next()
            .catch next
