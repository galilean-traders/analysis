module.exports = (res, error, response, body) ->
    # check if the oanda server sent an error and log it
    if "code" in body
        sails.log.error body
        res.serverError body
