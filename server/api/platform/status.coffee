module.exports = ->

log 			= require("log4js").getLogger()
restify			= require("restify")
platform_client	= require "./client"

# FIXME configurable endpoint

version = "v1"

module.exports.ping = (callback) ->
	platform_client.get "/ping", (err, req, res, obj) ->
		callback(err, obj)
	