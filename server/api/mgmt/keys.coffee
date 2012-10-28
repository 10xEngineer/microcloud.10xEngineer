module.exports = ->

log 		= require("log4js").getLogger()
restify		= require("restify")

# FIXME configurable endpoint
# TODO shared redis instance (setup connection, re-use it)

version = "v1"

module.exports.show = (key_name, user_id, callback) ->
	client = restify.createJsonClient
		url: 'http://api.labs.dev/'

	client.get "/v1/users/#{user_id}/keys/#{key_name}", (err, req, res, obj) ->
		callback(err, obj)
	