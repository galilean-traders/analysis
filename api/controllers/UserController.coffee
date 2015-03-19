#UserController.js 

#@module      :: Controller
#@description :: Provides the base user
#actions used to make waterlock work.

#@docs        :: http://waterlock.ninja/documentation

module.exports = require('waterlock').actions.user(
    create: (req, res) ->
        User
            .create params
            .exec (err, user) ->
                if err?
                    console.error err
                    res.error err
                else
                    waterlock.cycle.loginSuccess req, res, ua

    findOne: (req, res) -> res.json req.user

    update: (req, res) ->
        user = req.user
        if req.body.email
            user.auth.email = req.body.email
        if req.body.password
            user.auth.password = req.body.password
        if req.body.account_type
            user.account_type = req.body.account_type
        if req.body.oanda_token
            user.oanda_token = req.body.oanda_token
        if req.body.account_id
            user.account_id = req.body.account_id
        if req.body.favorites
            user.favorites = req.body.favorites
        user.save (err) ->
            if err?
                console.log err
                res.badRequest err
            res.json user
)
