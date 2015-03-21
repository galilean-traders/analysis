module.exports = (account_type, oanda_token, options) ->
    # add authorization header if the account is not a sandbox account
    unless account_type is "sandbox"
        options.headers =
            authorization: "Bearer #{oanda_token}"
