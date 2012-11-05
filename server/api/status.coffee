module.exports = ->

log 			= require("log4js").getLogger()
mongoose 		= require("mongoose")
async 			= require "async"
broker			= require "../broker"
restify			= require "restify"
platform_api 	= require("../api/platform")
Machine 		= mongoose.model "Machine"

module.exports.ping = (req, res, next) ->

	pingAPI = (callback) ->
		platform_api.status.ping (err, api) ->
			if err
				console.debug "platform_api err=#{err}"

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
		platform_api: pingAPI
		broker: pingBroker
		data_store: pingDataStore
	, (err, results) ->
		(code = 500 if results[key] == 'failed') for key of results

		res.send code || 200, results


module.exports.gecko_widget = (req, res, next) ->

	machineCount = (callback, results) ->
		Machine
			.find({archived: false, deleted_at: null})
			.exec (err, machines) ->
				if err
					return callback(new restify.InternalError("Unable to retrieve the list of machines: #{err}"))

				return callback(null, machines.length)

	async.auto
		machines: machineCount
	, (err, results) ->
		widget =
			item:
				text: "Active Machines"
				value: results.machines

		res.json widget
