zmq = require "zmq"

zmq_socket = zmq.socket('req')
zmq_socket.connect("tcp://localhost:41932")

module.exports =
    send: (object, callback) ->
        zmq_socket.send JSON.stringify object
        zmq_socket.on "message", callback
