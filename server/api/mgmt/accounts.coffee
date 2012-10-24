module.exports = ->

log 		= require("log4js").getLogger()
restify		= require("restify")

# FIXME configurable endpoint

version = "v1"

module.exports.show = (account_handle, callback) ->
	client = restify.createJsonClient
		url: 'http://api.labs.dev/'

	client.get "/v1/accounts/#{account_handle}", (err, req, res, obj) ->
		callback(err, obj)
	