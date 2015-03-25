request = require "request-promise"
    .defaults json: true

class OandaError extends Error
    constructor: (body, fileName, lineNumber) ->
        # build an Error object with the data from the oanda api:
        # http://developer.oanda.com/rest-live/troubleshooting-errors/
        message = "#{body.code}: #{body.message}"
        message += " #{body.moreInfo}" if body.moreInfo?
        super message, fileName, lineNumber

module.exports = (options) ->
    if not options.resolveWithFullResponse?
        request(options).then (body) ->
            throw new OandaError(body) if "code" in body
            return body
    else
        request(options)
            .then (response) ->
                console.log response.statusCode
                throw new OandaError response.body if "code" in response.body
                return response
            .catch (reason) ->
                console.log reason
                return reason
            
