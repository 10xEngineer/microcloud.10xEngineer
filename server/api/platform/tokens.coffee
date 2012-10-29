module.exports = ->

log 			= require("log4js").getLogger()
restify			= require("restify")
platform_client	= require "./client"

module.exports.show = (token, callback) ->
	platform_client.get "/v1/tokens/#{token}", (err, req, res, obj) ->
		callback(err, obj)
	