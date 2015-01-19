 # SignalController
 #
 # @description :: Server-side logic for managing instruments
 # @help        :: See http://links.sailsjs.org/docs/controllers

http = require "http"

module.exports =

    ema5ema10: (req, res) ->
        name = req.param 'name'
        request = http.request {
                port: 1337
                path: "/api/instrument/ema5?name=#{name}&count=15"
            }, (data) ->
                body = ""
                data.on "data", (chunk) ->
                    body += chunk
                data.on "end", ->
                    ema5 = JSON.parse(body)
                    length = ema5.length
                    time = ema5[length - 1].time
                    ema5 = ema5.map (d) -> d.value
                    request_ema10 = http.request {
                            port: 1337
                            path: "/api/instrument/ema10?name=#{name}&count=15"
                        }, (ema10) ->
                            ema10_body = ""
                            ema10.on "data", (chunk) ->
                                ema10_body += chunk
                            ema10.on "end", ->
                                ema10 = JSON.parse(ema10_body).map (d) -> d.value
                                ema5_upwards = ema5[length - 1] > ema5[length - 2]
                                ema10_upwards = ema10[length - 1] > ema10[length - 2]
                                ema5_cross_upwards_ema10 = ema5[length - 1] > ema10[length - 1] and ema5[length - 2] < ema10[length - 2]
                                ema5_cross_downwards_ema10 = ema5[length - 1] < ema10[length - 1] and ema5[length - 2] > ema10[length - 2]
                                long = ema5_upwards and ema10_upwards and ema5_cross_upwards_ema10
                                short = !ema5_upwards and !ema10_upwards and ema5_cross_downwards_ema10
                                if long
                                    value = "long"
                                else if short
                                    value = "short"
                                else
                                    value = null
                                response = {
                                    time: time
                                    value: value
                                }
                                console.log "response is", response
                                res.json response
                        .on 'error', (e) ->
                            console.warn "ERROR: #{e.message}" 
                    request_ema10.setHeader("access-token", req.headers["access-token"])
                    request_ema10.end()
            .on 'error', (e) ->
                console.warn "ERROR: #{e.message}" 
        request.setHeader("access-token", req.headers["access-token"])
        request.end()

    rsi: (req, res) ->
        name = req.param 'name'
        request = http.request {
                port: 1337
                path: "/api/instrument/rsi?name=#{name}&count=15"
            }, (data) ->
                body = ""
                data.on "data", (chunk) ->
                    body += chunk
                data.on "end", ->
                    json = JSON.parse(body)
                    length = json.length
                    time = json[length - 1].time
                    json = json.map (d) -> d.value
                    [..., second, first] = json
                    upwards = second < first
                    long_values = 50 <= first < 70
                    short_values = 30 <= first < 50
                    if upwards and long_values
                        value = "long"
                    else if !upwards and short_values
                        value = "short"
                    else
                        value = null
                    response = {
                        time: time
                        value: value
                    }
                    res.json response
            .on 'error', (e) ->
                console.warn "ERROR: #{e.message}" 
        request.setHeader("access-token", req.headers["access-token"])
        request.end()

    adr: (req, res) ->
        name = req.param 'name'
        request = http.request {
                port: 1337
                path: "/api/instrument/adr?name=#{name}&count=15"
            }, (data) ->
                body = ""
                data.on "data", (chunk) ->
                    body += chunk
                data.on "end", ->
                    json = JSON.parse(body)
                    length = json.length
                    time = json[length - 1].time
                    json = json.map (d) -> d.value
                    [..., first] = json
                    response = {
                        time: time
                        value: first > 100
                    }
                    res.json response
            .on 'error', (e) ->
                console.warn "ERROR: #{e.message}" 
        request.setHeader("access-token", req.headers["access-token"])
        request.end()

    stoch: (req, res) ->
        name = req.param 'name'
        request = http.request {
                port: 1337
                path: "/api/instrument/stoch?name=#{name}&count=15"
            }, (data) ->
                body = ""
                data.on "data", (chunk) ->
                    body += chunk
                data.on "end", ->
                    json = JSON.parse(body)[0].values
                    length = json.length
                    time = json[length - 1].time
                    json = json.map (d) -> d.value
                    [..., second, first] = json
                    upwards = second < first
                    range = 20 < first < 80
                    if upwards and range
                        value = "long"
                    else if !upwards and range
                        value = "short"
                    else
                        value = null
                    response = {
                        time: time
                        value: value
                    }
                    res.json response
            .on 'error', (e) ->
                console.warn "ERROR: #{e.message}" 
        request.setHeader("access-token", req.headers["access-token"])
        request.end()
