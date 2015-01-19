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
            if err
                console.log err
            else
                waterlock.engine.attachAuthToUser auth, user, (err, ua) ->
                    if err
                        res.json err
                    else
                        waterlock.cycle.loginSuccess req, res, ua
)
