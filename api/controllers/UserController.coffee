#UserController.js 

#@module      :: Controller
#@description :: Provides the base user
#actions used to make waterlock work.

#@docs        :: http://waterlock.ninja/documentation

whitelist = [
    "email"
    "password"
    "account_type"
    "account_id"
    "oanda_token"
]

module.exports = require('waterlock').actions.user(

    create: (req, res) ->
        params = waterlock._utils.allParams req
        safe_params = _.pick params, whitelist
        safe_params.auth =
            email: safe_params.email
            password: safe_params.password
        delete safe_params.email
        delete safe_params.password
        User.create safe_params
            .then (user) ->
                waterlock.cycle.loginSuccess req, res, user
            .catch (error) ->
                console.log error
                res.badRequest error

    findOne: (req, res) -> res.json req.user

    update: (req, res) ->
        params = waterlock._utils.allParams req
        safe_params = _.pick params, (key) -> key in whitelist
        safe_params.auth =
            email: safe_params.email
            password: safe_params.password
        delete safe_params.email
        delete safe_params.password
        User.update {id: req.user.id}, safe_params
            .then (user) ->
                res.json user[0]
            .catch (error) ->
                console.error err
                res.error err
)
