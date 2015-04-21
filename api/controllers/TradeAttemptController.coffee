 # @help        :: See http://links.sailsjs.org/docs/controllers

whitelist = [
    "instrument"
    "time"
    "adr"
    "stoch"
    "ema5ema10"
    "rsi"
    "status"
]

module.exports =

    find: (req, res, next) ->
        safe_params = _.pick req.body, whitelist
        _.merge safe_params, {user: req.user.id}
        TradeAttempt.find safe_params
            .then res.json
            .catch next
