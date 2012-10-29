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

	formatKeys = (callback, results) ->
		output = "" 

		for entry in results.key_data
			# TODO add ,no-pty
			output = output + "command=\"/tmp/somescript.sh lab #{entry.machine.name}\",no-port-forwarding #{entry.key}\n"

		return callback(null, output)			

	async.auto 
		machines: getMachines
		key_data: ['machines', buildKeyData]
		authorized_keys: ['key_data', formatKeys]
	, (err, results) ->
		if err
			return next(err)

		if req.headers.accept == 'text/plain'
			res.send results.authorized_keys
		else
			res.json results.key_data

