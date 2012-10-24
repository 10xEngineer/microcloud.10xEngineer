module.exports = ->

log 		= require("log4js").getLogger()
mongoose 	= require("mongoose")
async 		= require "async"
broker		= require "../broker"
restify		= require "restify"
mgmt_api 	= require("../api/mgmt/client")

module.exports.ping = (req, res, next) ->

	pingAPI = (callback) ->
		mgmt_api.status.ping (err, api) ->
			unless api and api["status"] == "ok"
				return callback(null, "failed")

			callback(null, "ok")

	pingDataStore = (callback) ->
		mongoose.connection.db.collectionNames (err,names) ->
			if err
				return callback(null, "failed")

			callback(null, "ok")

	pingBroker = (callback) ->
		# TODO add broker auto expiry timeout
		breq = broker.dispatch 'dummy', 'ping', {}
		breq.on 'data', (message) ->
			return callback(null, "ok")

		breq.on 'error', (message) ->
			return callback(null, "failed")

	async.auto
		mgmt_api: pingAPI
		broker: pingBroker
		data_store: pingDataStore
	, (err, results) ->
		(code = 500 if results[key] == 'failed') for key of results

		res.send code || 200, results



