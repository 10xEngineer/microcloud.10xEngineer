module.exports = ->

log 		= require("log4js").getLogger()
mongoose 	= require("mongoose")
async 		= require "async"

Machine 	= mongoose.model 'Machine'

# TODO token authentication

module.exports.show = (req, res, next) ->
	getMachines = (callback, results) ->
		Machine
			.find({archived: false})
			.where("ssh_proxy").elemMatch({proxy_user: req.params.user})
			.exec (err, machines) ->
				if err
					return callback(new restify.InternalError("Unable to query available proxy keys: #{err}"))

				return callback(null, machines)

	buildKeyData = (callback, results) ->
		keys = []

		for machine in results.machines
			for proxy in machine.ssh_proxy
				if proxy.proxy_user == req.params.user
					key_data = 
						machine: 
							id: machine._id
							name: machine.name
						key: proxy.public_key


					keys.push(key_data)

		return callback(null, keys)

	async.auto 
		machines: getMachines
		key_data: ['machines', buildKeyData]
	, (err, results) ->
		if err
			return next(err)

		res.send results.key_data

