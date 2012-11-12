log 			= require("log4js").getLogger()
platform_api	= require("../api/platform")
config 			= require("../config")
lru				= require("lru-cache")
use_cache 		= config.get("platform:cache")

# cache support
options =
	max: 50
	maxAge: 15*1000

cache = lru(options)

reporting = () ->
	log.info "cache=platform_api enabled=#{use_cache} size=#{cache.length}"

setInterval(reporting, 1000*60)

module.exports.get_token = (token, callback) ->
	access_token = cache.get token if use_cache

	unless access_token
		platform_api.tokens.show token, (err, access_token) ->
			cache.set token, access_token if use_cache

			return callback(null, access_token)
	else
		callback(null, access_token)


module.exports.get_account = (account_handle, callback) ->
	platform_api.accounts.show account_handle, callback