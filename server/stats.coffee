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
source = config.get("deploy")

api_calls = 0

module.exports.api_calls_log = (req, res, next) ->
	api_calls++

	return next()

module.exports.setup = () ->
	Machine 	= mongoose.model "Machine"

	activeMachines = (callback, results) ->
		Machine
			.count({deleted_at: null, archived: false})
			.exec callback

	apiCalls = (callback, results) ->
		calls = api_calls
		api_calls = 0

		return callback(null, calls)

	submitStatistics = () ->
		async.auto
			api_calls: apiCalls
			active_machines: activeMachines

		, (err, results) ->
			if err
				log.error "Unable to submit statistics reason='#{err}'"

				return

			client.post '/metrics',
				gauges: [
					{name: 'machines_active', value: results.active_machines, source: source},
					{name: 'api_calls', value: results.api_calls, source: source}
				]
			, (err, response) ->
				if err
					return log.error "Unable to submit statistics err=#{err}"

				log.debug "statistics submitted to metrics"

	# submit stats every minute
	setInterval submitStatistics, (300)*1000 if env == "production"