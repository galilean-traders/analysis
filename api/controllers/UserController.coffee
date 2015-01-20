#UserController.js 

#@module      :: Controller
#@description :: Provides the base user
#actions used to make waterlock work.

#@docs        :: http://waterlock.ninja/documentation

module.exports = require('waterlock').actions.user(
    create: (req, res) ->
        params = waterlock._utils.allParams req 
        auth =
            email: params.email,
            password: params.password
        delete params.email
        delete params.password
        User
            .create params
            .exec (err, user) ->
                if err?
                    console.log err
                else
                    waterlock.engine.attachAuthToUser auth, user, (err, ua) ->
                        if err?
                            res.json err
                        else
                            waterlock.cycle.loginSuccess req, res, ua

    findOne: (req, res) ->
        token = waterlock.jwt.decode req.headers['access-token'], waterlock.config.jsonWebTokens.secret
        waterlock.validator.findUserFromToken token, (err, user) ->
            if err?
                res.notFound()
            else
                res.json user

    update: (req, res) ->
        token = waterlock.jwt.decode req.headers['access-token'], waterlock.config.jsonWebTokens.secret
        waterlock.validator.findUserFromToken token, (err, user) ->
            if err?
                res.forbidden()
            User.findOne user.id
                .exec (_err, _user) ->
                    if _err?
                        console.log err
                        res.badRequest()
                    if req.body.email
                        _user.auth.email = req.body.email
                    if req.body.password
                        _user.auth.password = req.body.password
                    if req.body.account_type
                        _user.account_type = req.body.account_type
                    if req.body.oanda_token
                        _user.oanda_token = req.body.oanda_token
                    _user.save (__err) ->
                        if __err?
                            console.log __err
                            res.badRequest __err
                        res.json _user
)
