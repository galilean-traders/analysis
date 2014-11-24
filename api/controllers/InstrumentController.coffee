 # InstrumentController
 #
 # @description :: Server-side logic for managing instruments
 # @help        :: See http://links.sailsjs.org/docs/controllers

https = require "https"
http = require "http"
zmq = require "zmq"

module.exports = {
    rawdata: (req, res) ->
        name = req.param 'name'
        granularity = req.param 'granularity'
        count = req.param 'count'
        https.get "https://api-sandbox.oanda.com/v1/candles?instrument=#{name}&count=#{count}&candleFormat=midpoint&granularity=#{granularity}&dailyAlignment=0&alignmentTimezone=Europe%2FZurich", (data) ->
            data.pipe res
        .on 'error', (e) ->
            console.warn "ERROR: #{e.message}" 

    EMA5: (req, res) ->
        name = req.param 'name'
        request = http.request {
                port: 1337
                path: "/instrument/rawdata?name=#{name}&granularity=M5&count=20"
            }, (data) ->
                body = ""
                data.on "data", (chunk) ->
                    body += chunk
                data.on "end", ->
                    candles = JSON.parse(body).candles
                    zmq_socket = zmq.socket('req')
                    zmq_socket.connect("tcp://localhost:41932")
                    zmq_socket.send(
                        JSON.stringify(
                            {
                                fun: "EMA"
                                args: {
                                    x: candles.map (d) ->
                                        d.closeMid
                                    n: 5
                                }
                            }
                        )
                    )
                    zmq_socket.on('message', (data) ->
                        console.log('answer data ' + data)
                        res.json JSON.parse("" + data).map (d, i) ->
                            {
                                time: candles[i].time
                                value: d
                            }
                    )
            .on 'error', (e) ->
                console.warn "ERROR: #{e.message}" 
        request.end()

    RSI: (req, res) ->
        name = req.param 'name'
        request = http.request {
                port: 1337
                path: "/instrument/rawdata?name=#{name}&granularity=M5&count=20"
            }, (data) ->
                body = ""
                data.on "data", (chunk) ->
                    body += chunk
                data.on "end", ->
                    candles = JSON.parse(body).candles
                    zmq_socket = zmq.socket('req')
                    zmq_socket.connect("tcp://localhost:41932")
                    zmq_socket.send(
                        JSON.stringify(
                            {
                                fun: "RSI"
                                args: {
                                    price: candles.map (d) ->
                                        d.closeMid
                                    n: 14
                                }
                            }
                        )
                    )
                    zmq_socket.on('message', (data) ->
                        console.log('answer data ' + data)
                        res.json JSON.parse("" + data).map (d, i) ->
                            {
                                time: candles[i].time
                                value: d
                            }
                    )
            .on 'error', (e) ->
                console.warn "ERROR: #{e.message}" 
        request.end()

    stoch: (req, res) ->
        name = req.param 'name'
        request = http.request {
                port: 1337
                path: "/instrument/rawdata?name=#{name}&granularity=M5&count=20"
            }, (data) ->
                body = ""
                data.on "data", (chunk) ->
                    body += chunk
                data.on "end", ->
                    candles = JSON.parse(body).candles
                    zmq_socket = zmq.socket('req')
                    zmq_socket.connect("tcp://localhost:41932")
                    zmq_socket.send(
                        JSON.stringify(
                            {
                                fun: "stoch"
                                args: {
                                    HLC: candles.map (d) ->
                                        d.closeMid
                                    nFastK: 14
                                    nFastD: 3
                                    nSlowD: 3
                                }
                            }
                        )
                    )
                    zmq_socket.on('message', (data) ->
                        console.log('answer data ' + data)
                        res.json JSON.parse("" + data).map (d, i) ->
                            {
                                time: candles[i].time
                                value: d
                            }
                    )
            .on 'error', (e) ->
                console.warn "ERROR: #{e.message}" 
        request.end()

    ADR: (req, res) ->
        name = req.param 'name'
        request = http.request {
                port: 1337
                path: "/instrument/rawdata?name=#{name}&granularity=D&count=60"
            }, (data) ->
                body = ""
                data.on "data", (chunk) ->
                    body += chunk
                data.on "end", ->
                    candles = JSON.parse(body).candles
                    zmq_socket = zmq.socket('req')
                    zmq_socket.connect("tcp://localhost:41932")
                    zmq_socket.send(
                        JSON.stringify(
                            {
                                fun: "SMA"
                                args: {
                                    x: candles.map (d) ->
                                        d.closeMid - d.openMid
                                    n: 14
                                }
                            }
                        )
                    )
                    zmq_socket.on('message', (data) ->
                        console.log('answer data ' + data)
                        res.json JSON.parse("" + data).map (d, i) ->
                            {
                                time: candles[i].time
                                value: d
                            }
                    )
            .on 'error', (e) ->
                console.warn "ERROR: #{e.message}" 
        request.end()
}
