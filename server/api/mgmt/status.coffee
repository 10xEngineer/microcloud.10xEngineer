module.exports = ->

log 		= require("log4js").getLogger()
restify		= require("restify")

# FIXME configurable endpoint

version = "v1"

module.exports.ping = (callback) ->
	client = restify.createJsonClient
		url: 'http://api.labs.dev/'

	client.get "/v1/ping", (err, req, res, obj) ->
		callback(err, obj)
	