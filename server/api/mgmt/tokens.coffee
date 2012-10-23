module.exports = ->

log 		= require("log4js").getLogger()
restify		= require("restify")

# FIXME configurable endpoint
# TODO shared redis instance (setup connection, re-use it)

version = "v1"

module.exports.show = (token, callback) ->
	client = restify.createJsonClient
		url: 'http://api.labs.dev/'

	client.get "/v1/tokens/#{token}", (err, req, res, obj) ->
		callback(err, obj)
	