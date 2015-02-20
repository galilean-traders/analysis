
#User

#@module      :: Model
#@description :: This is the base user model
#@docs        :: http://waterlock.ninja/documentation


module.exports =
  attributes: require('waterlock').models.user.attributes(
      oanda_token: "string"
      account_type: "string"
      account_id: "string"
      favorites: "array"
  )
  beforeCreate: require('waterlock').models.user.beforeCreate
  beforeUpdate: require('waterlock').models.user.beforeUpdate
