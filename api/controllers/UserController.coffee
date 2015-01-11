 # UserController
 #
 # @description :: Server-side logic for managing users
 # @help        :: See http://links.sailsjs.org/docs/controllers

passport = require 'passport' 

module.exports = {
    login: (req, res) ->
        passport.authenticate('local', (err, user, info) ->
            if err? or not user
                res.send err 
                return res.send {message: 'login failed'}
            req.logIn user, (err) ->
                res.send err if err?
                return res.send {message: 'login successful'}
        )(req, res)

    logout: (req, res) ->
        req.logOut()
        res.send 'logout successful' 
}

module.exports.blueprints = {
    actions: true,
    rest: true,
    shortcuts: true
}
