 # InstrumentController
 #
 # @description :: Server-side logic for managing instruments
 # @help        :: See http://links.sailsjs.org/docs/controllers

http = require "https"

module.exports = {
    refresh: (req, res) ->
        http.get("https://api-sandbox.oanda.com/v1/candles?instrument=EUR_USD&count=2&candleFormat=midpoint&granularity=M5&dailyAlignment=0&alignmentTimezone=America%2FNew_York", (googleres) ->
            body = ""
            googleres.on "data", (chunk) ->
                body += chunk
            googleres.on "end", ->
                console.log "BODY: #{body}"
                res.send JSON.parse(body)["candles"][0]

        ).on('error', (e) ->
            console.log("Got error: " + e.message)
        )

    ema5: (req, res) ->
        res.send "Hello ema5!"
}
