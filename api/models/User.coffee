 # User.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models

module.exports =

    attributes: {
        username: 'string'
        password: 'string'
        token: 'string'
        toJSON: ->
            obj = this.toObject()
            delete obj.password
            return obj
    }

    beforeCreate: (attrs, next) ->
        bcrypt = require 'bcrypt' 

        bcrypt.genSalt 10, (err, salt) ->
            return next err if err?

            bcrypt.hash attrs.password, salt, (err, hash) ->
                return next err if err?
                attrs.password = hash
                next(null, attrs)


