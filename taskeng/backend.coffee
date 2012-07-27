log = require("log4js").getLogger()
redis = require "redis"
client = redis.createClient()

class Backend
	constructor: (@id) ->

	register: ->
		client.set "taskeng:runners:#{@id}", new Date().toISOString()

module.exports = Backend