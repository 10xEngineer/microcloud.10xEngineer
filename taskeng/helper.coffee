broker = require "../server/broker"
restify = require "restify"

class BrokerHelper
	constructor: (@runner) ->

	dispatch: (service, method, options) ->
		return broker.dispatch service, method, options

	get: (url, cb) ->
		@client().get(url, cb)

	post: (url, data, cb) ->
		@client().post(url, data, cb)

	delete: (url, cb) ->
		@client().del(url, cb)

	createSubJob: (parent_id, data) ->
		@runner.createJob data, parent_id

	client: ->
		client = restify.createJsonClient 
			url: "http://localhost:8080"
			version: "*"

		return client

module.exports = BrokerHelper