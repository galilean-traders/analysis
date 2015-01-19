'use strict'
#hasJsonWebToken

#@module      :: Policy
#@description :: Assumes that your request has an jwt;

#@docs        :: http://waterlock.ninja/documentation

module.exports = (req, res, next) ->
    req.headers['access_token'] = req.headers['access-token']
    # copy headers as in:
    # https://github.com/waterlock/waterlock/issues/43
    waterlock.validator.validateTokenRequest req, (err, user) ->
        console.log err, user
        if err?
            return res.forbidden err
        # valid request
        next()
