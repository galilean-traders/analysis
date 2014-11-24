zmq = require "zmq"

module.exports =
    send: (object, callback) ->
        zmq_socket = zmq.socket('req')
        zmq_socket.connect("tcp://localhost:41932")
        zmq_socket.send JSON.stringify object
        zmq_socket.on "message", callback
