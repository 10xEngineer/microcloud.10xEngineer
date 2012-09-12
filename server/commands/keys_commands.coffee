module.exports = ->

log = require("log4js").getLogger()
mongoose = require("mongoose")
Keypair = mongoose.model("Keypair")
broker = require("../broker")

module.exports.create = (req, res, next) ->
	passphrase = null
	name = null
	if req.body
		data = JSON.parse req.body

		name = data.name || null
		passphrase = data.passphrase || null

	unless name?
		res.send 412, 
			reason: "keypair name required."

	options = {}
	options["passphrase"] = passphrase if passphrase?

	req = broker.dispatch 'key', 'create', options
	req.on 'data', (message) ->
		key_data = 
			name: name
			fingerprint: message.options.fingerprint
			ssh_public_key: message.options.public

		keypair = new Keypair(key_data)
		keypair.save (err) ->
			if err
				log.error "unable to save keypair=#{message.options.fingerprint}"
				return res.send 409, 
					reason: err.message

			res.send 201,
				name: data.name
				fingerprint: key_data.fingerprint
				identity: message.options.identity

	req.on 'error', (message) ->
		res.send 500, message

module.exports.show = (req, res, next) ->
	Keypair
		.findOne({name: req.params.key})
		.exec (err, keypair) ->
			if keypair
				res.send keypair
			else
				res.send 404,
					reason: "keypair '#{req.params.key}' not found."

module.exports.destroy = (req, res, next) ->
	# FIXME use soft-delete
	Keypair
		.findOne({name: req.params.key})
		.exec (err, keypair) ->
			if keypair
				keypair.remove (err) ->
					if err
						log.warn "unable to remove keypair=#{req.params.key} reason=#{err.message}"
						return res.send 500,
							reason: err.message

					res.send 
						status: "deleted"

			else
				res.send 404,
					reason: "keypair '#{req.params.key}' not found."
