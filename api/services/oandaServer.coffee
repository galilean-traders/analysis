module.exports = (account_type) ->
    server = switch
        when account_type is "sandbox" then "api-sandbox.oanda.com"
        when account_type is "practice" then "api-fxpractice.oanda.com"
        when account_type is "trade" then "api-fxtrade.oanda.com"
    return server
