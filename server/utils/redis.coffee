log 		= require("log4js").getLogger()
redis 		= require("redis")

class RedisClient
	# TODO add nconf support
	
	instance: null

	@getInstance: ->
		unless RedisClient::instance
			RedisClient::instance = redis.createClient()

			log.debug "new redis instance created"

		return RedisClient::instance

module.exports = RedisClient