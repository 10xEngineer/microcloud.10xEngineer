module.exports = ->

log 			= require("log4js").getLogger()
restify			= require("restify")
platform_client	= require "./client"

module.exports.show = (key_name, user_id, callback) ->
	platform_client.get "/v1/users/#{user_id}/keys/#{key_name}", (err, req, res, obj) ->
		callback(err, obj)
	