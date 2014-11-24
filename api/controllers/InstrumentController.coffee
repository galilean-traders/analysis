 # InstrumentController
 #
 # @description :: Server-side logic for managing instruments
 # @help        :: See http://links.sailsjs.org/docs/controllers

https = require "https"
http = require "http"

module.exports =
    rawdata: (req, res) ->
        name = req.param 'name'
        granularity = req.param 'granularity'
        count = req.param 'count'
        https.get "https://api-sandbox.oanda.com/v1/candles?instrument=#{name}&count=#{count}&candleFormat=midpoint&granularity=#{granularity}&dailyAlignment=0&alignmentTimezone=Europe%2FZurich", (data) ->
            data.pipe res
        .on 'error', (e) ->
            console.warn "ERROR: #{e.message}" 

    ema5: (req, res) ->
        name = req.param 'name'
        request = http.request {
                port: 1337
                path: "/api/instrument/rawdata?name=#{name}&granularity=M5&count=20"
            }, (data) ->
                body = ""
                data.on "data", (chunk) ->
                    body += chunk
                data.on "end", ->
                    candles = JSON.parse(body).candles
                    zmq_object =
                        fun: "EMA"
                        args:
                            x: candles.map (d) ->
                                d.closeMid
                            n: 5
                    zmqUtils.send zmq_object, (data) ->
                        console.log "ema5 answer data: #{data}"
                        res.json rUtils.filter_NA(data).map (d, i) ->
                            time: candles[i].time
                            value: d
            .on 'error', (e) ->
                console.warn "ERROR: #{e.message}" 
        request.end()

    ema10: (req, res) ->
        name = req.param 'name'
        request = http.request {
                port: 1337
                path: "/api/instrument/rawdata?name=#{name}&granularity=M5&count=20"
            }, (data) ->
                body = ""
                data.on "data", (chunk) ->
                    body += chunk
                data.on "end", ->
                    candles = JSON.parse(body).candles
                    zmq_object =
                        fun: "EMA"
                        args:
                            x: candles.map (d) ->
                                d.closeMid
                            n: 10
                    zmqUtils.send zmq_object, (data) ->
                        console.log "ema10 answer data: #{data}"
                        res.json rUtils.filter_NA(data).map (d, i) ->
                            time: candles[i].time
                            value: d
            .on 'error', (e) ->
                console.warn "ERROR: #{e.message}" 
        request.end()

    rsi: (req, res) ->
        name = req.param 'name'
        request = http.request {
                port: 1337
                path: "/api/instrument/rawdata?name=#{name}&granularity=M5&count=20"
            }, (data) ->
                body = ""
                data.on "data", (chunk) ->
                    body += chunk
                data.on "end", ->
                    candles = JSON.parse(body).candles
                    zmq_object =
                        fun: "RSI"
                        args:
                            price: candles.map (d) ->
                                d.closeMid
                            n: 14
                    zmqUtils.send zmq_object, (data) ->
                        console.log "rsi answer data: #{data}"
                        res.json rUtils.filter_NA(data).map (d, i) ->
                            time: candles[i].time
                            value: d
            .on 'error', (e) ->
                console.warn "ERROR: #{e.message}" 
        request.end()

    stoch: (req, res) ->
        name = req.param 'name'
        request = http.request {
                port: 1337
                path: "/api/instrument/rawdata?name=#{name}&granularity=M5&count=20"
            }, (data) ->
                body = ""
                data.on "data", (chunk) ->
                    body += chunk
                data.on "end", ->
                    candles = JSON.parse(body).candles
                    zmq_object =
                        fun: "stoch"
                        args:
                            HLC: candles.map (d) ->
                                d.closeMid
                            nFastK: 14
                            nFastD: 3
                            nSlowD: 3
                    zmqUtils.send zmq_object, (data) ->
                        console.log "stoch answer data: #{data}"
                        res.json rUtils.filter_NA(data).map (d, i) ->
                            time: candles[i].time
                            value: d
            .on 'error', (e) ->
                console.warn "ERROR: #{e.message}" 
        request.end()

    adr: (req, res) ->
        name = req.param 'name'
        request = http.request {
                port: 1337
                path: "/api/instrument/rawdata?name=#{name}&granularity=D&count=60"
            }, (data) ->
                body = ""
                data.on "data", (chunk) ->
                    body += chunk
                data.on "end", ->
                    candles = JSON.parse(body).candles
                    zmq_object =
                        fun: "SMA"
                        args:
                            x: candles.map (d) ->
                                d.highMid - d.lowMid
                            n: 14
                    zmqUtils.send zmq_object, (data) ->
                        console.log "adr answer data: #{data}"
                        res.json rUtils.filter_NA(data).map (d, i) ->
                            time: candles[i].time
                            value: d * 1e4 # multiply by pip value
            .on 'error', (e) ->
                console.warn "ERROR: #{e.message}" 
        request.end()
