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
				fingerprint: key_data.fingerprint
				identity: message.options.identity

module.exports.show = (req, res, next) ->
	# FIXME not implemented
	res.send {}

module.exports.destroy = (req, res, next) ->
	Keypair
		.findOne(fingerprint)
	# FIXME not implemented
	res.send {}
