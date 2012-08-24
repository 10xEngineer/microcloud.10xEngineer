module.exports = ->

redis = require("redis")
client = redis.createClient()
log = require("log4js").getLogger()
http = require("http")
uuid = require("node-uuid")
crypto = require('crypto')
fs = require('fs')

MAGIC_STRING = "GyFfJywqgwVcXeY24J"

#
# create a VM session (lab:user@vm_name -i private_key)
#
module.exports.create = (req, res, next) ->
	data = req.body

	unless data.lab? and data.vm_name? and data.user? and data.private_key?
		return res.send 412, 
			reason: "lab, user, vm_name and private_key required."

	id = uuid.v4()

	get_vms = (lab, callback) ->
		# FIXME hardcoded
		url = "http://bunny.laststation.net:8080/labs/#{data.lab}/vms"

		http.get url, (_res) ->
			vms_raw = ""

			_res.on 'data', (chunk) ->
				vms_raw += chunk

			_res.on 'end', () ->
				if _res.statusCode != 200
					return res.send _res.statusCode, "can't get lab VMs: #{_res.statusCode}"

				vms = JSON.parse vms_raw

				find_vm vms, data.vm_name, (vm) ->
					unless vm
						callback("uknown vm_name=#{data.vm_name}")

					callback(null, vm)

	find_vm = (vms, vm_name, callback) ->
		for a_vm in vms 
			if a_vm.vm_name is vm_name
				return callback(a_vm)

		callback(null)

	generate_secret = (data, callback) ->
		shasum = crypto.createHash('sha1')
		shasum.update(data)
		shasum.update(MAGIC_STRING)

		callback(shasum.digest('hex'))

	store_session = (session_id, user, vm, private_key, callback) ->
		hash = "#{session_id}:#{user}@#{vm.descriptor.ip_addr}"

		generate_secret hash, (secret) ->
			client.multi()
				.hset(session_id, "secret", secret)
				.hset(session_id, "user", user)
				.hset(session_id, "host", vm.descriptor.ip_addr)
				.exec (err, replies) ->
					unless err
						save_key session_id, private_key, (err) ->
							if err
								return callback err

							log.debug "session=#{session_id} host=#{vm.descriptor.ip_addr} created"
							callback null, secret
					else
						callback err

	save_key = (session_id, key, callback) ->
		# FIXME proper localtion
		fname = "/tmp/#{session_id}.key"

		fs.writeFile fname, key, (err) ->
			if err
				return callback err

			callback(null)

	# get the vm
	get_vms data.lab, (err, vm) ->
		if err
			return res.send 417, err

		store_session id, data.user, vm, data.private_key, (err, secret) ->
			if err
				return res.send 500, err

			res.send 
				id: id
				secret: secret

		# TODO store private_key to a file
		# DONE










