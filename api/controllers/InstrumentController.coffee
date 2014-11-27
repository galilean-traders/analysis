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
            body = ""
            data.on "data", (chunk) ->
                body += chunk
            data.on "end", ->
                res.send body
        .on 'error', (e) ->
            console.warn "ERROR: #{e.message}" 

    ema5: (req, res) ->
        name = req.param 'name'
        count = parseInt(req.param('count')) or 20
        request = http.request {
                port: 1337
                path: "/api/instrument/rawdata?name=#{name}&granularity=M5&count=#{4 + count}"
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
                        res.json rUtils.filter_NA(data).map (d) ->
                            time: candles[d.index].time
                            value: d.value
            .on 'error', (e) ->
                console.warn "ERROR: #{e.message}" 
        request.end()

    ema10: (req, res) ->
        name = req.param 'name'
        count = parseInt(req.param('count'))  or 20
        request = http.request {
                port: 1337
                path: "/api/instrument/rawdata?name=#{name}&granularity=M5&count=#{9 + count}"
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
                        res.json rUtils.filter_NA(data).map (d) ->
                            time: candles[d.index].time
                            value: d.value
            .on 'error', (e) ->
                console.warn "ERROR: #{e.message}" 
        request.end()

    rsi: (req, res) ->
        name = req.param 'name'
        count = parseInt(req.param('count')) or 20
        request = http.request {
                port: 1337
                path: "/api/instrument/rawdata?name=#{name}&granularity=M5&count=#{14 + count}"
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
                        res.json rUtils.filter_NA(data).map (d) ->
                            time: candles[d.index].time
                            value: d.value
            .on 'error', (e) ->
                console.warn "ERROR: #{e.message}" 
        request.end()

    stoch: (req, res) ->
        name = req.param 'name'
        count = parseInt(req.param('count')) or 20
        request = http.request {
                port: 1337
                path: "/api/instrument/rawdata?name=#{name}&granularity=M5&count=#{18 + count}"
            }, (data) ->
                body = ""
                data.on "data", (chunk) ->
                    body += chunk
                data.on "end", ->
                    candles = JSON.parse(body).candles
                    zmq_object =
                        fun: "stoch.json"
                        args:
                            data: candles
                    zmqUtils.send zmq_object, (data) ->
                        output = JSON.parse "#{data}"
                        response = [{
                            name: "fastK"
                            values: output.fastK.map (d, i) ->
                                time: candles[i].time
                                value: d
                        },{
                            name: "fastD"
                            values: output.fastD.map (d, i) ->
                                time: candles[i].time
                                value: d
                        },{
                            name: "slowD"
                            values: output.slowD.map (d, i) ->
                                time: candles[i].time
                                value: d
                        }]
                        # return only values for which slowD is not NA
                        res.json response.map (d) ->
                            name: d.name
                            values: d.values.filter (e, i) ->
                                response[2].values[i].value isnt "NA"
            .on 'error', (e) ->
                console.warn "ERROR: #{e.message}" 
        request.end()

    adr: (req, res) ->
        name = req.param 'name'
        count = parseInt(req.param('count')) or 20
        request = http.request {
                port: 1337
                path: "/api/instrument/rawdata?name=#{name}&granularity=D&count=#{13 + count}"
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
                        res.json rUtils.filter_NA(data).map (d) ->
                            time: candles[d.index].time
                            value: 1e4 * d.value # times pip value
            .on 'error', (e) ->
                console.warn "ERROR: #{e.message}" 
        request.end()
