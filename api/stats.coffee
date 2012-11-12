log 		= require("log4js").getLogger()
mongoose 	= require("mongoose")
nconf 		= require("nconf")
config 		= require("./config")
async 		= require("async")
metrics 	= require("librato-metrics")

client = metrics.createClient
	email: config.get("metrics:client")
	token: config.get("metrics:token")

env = nconf.get('NODE_ENV')
source = "api-#{env}"

module.exports.setup = () ->
	User 	= mongoose.model "User"
	Key 	= mongoose.model "Key"

	totalUsers = (callback, results) ->
		User
			.count()
			.exec(callback)

	totalKeys = (callback, results) ->
		Key
			.count()
			.exec(callback)			

	submitStatistics = () ->
		async.auto
			total_users: totalUsers
			total_keys: totalKeys
		, (err, results) ->
			if err
				log.error "Unable to submit statistics reason='#{err}'"

				return

			client.post '/metrics',
				counters: [
					{name: 'users', value: results.total_users, source: source},
					{name: 'keys', value: results.total_keys, source: source}
				]
			, (err, response) ->
				if err
					return log.error "Unable to submit statistics err=#{err}"

				log.debug "statistics submitted to metrics"

	# submit stats every minute
	setInterval submitStatistics, (300)*1000 if env == "production"