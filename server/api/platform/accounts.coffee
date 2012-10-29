module.exports = ->

log 			= require("log4js").getLogger()
restify			= require("restify")
platform_client	= require "./client"

module.exports.show = (account_handle, callback) ->
	platform_client.get "/accounts/#{account_handle}", (err, req, res, obj) ->
		callback(err, obj)
	