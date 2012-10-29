module.exports = ->

log 			= require("log4js").getLogger()
restify			= require("restify")
platform_api	= require "./platform_client"

# FIXME configurable endpoint

version = "v1"

module.exports.ping = (callback) ->
	platform_api.get "/v1/ping", (err, req, res, obj) ->
		callback(err, obj)
	