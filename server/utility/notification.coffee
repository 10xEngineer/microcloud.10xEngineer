http = require 'http'
config = require '../config'

module.exports.send = (data, cb = ->) ->
  req = http.request
    host    : '0.0.0.0'
    port    : config.get('server:port')
    path    : '/notification'
    method  : 'POST'
    headers : 'Content-Type': 'application/json'
  , cb
  req.end JSON.stringify data