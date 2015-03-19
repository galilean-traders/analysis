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
        safe_params = _.pick req.body, whitelist
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
        safe_params = _.pick req.body, whitelist
        _.merge safe_params, {auth: req.user.auth}
        User.update req.user.id, safe_params
            .then (user) ->
                res.json user[0]
            .catch (error) ->
                console.error error
                res.badRequest error

    delete: (req, res) ->
        User.destroy req.user.id
            .then (user) ->
                res.json user
            .catch (error) ->
                console.error error
                res.badRequest error
)
