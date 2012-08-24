module.exports = ->

redis = require("redis")
client = redis.createClient()
log = require("log4js").getLogger()
http = require("http")
uuid = require("node-uuid")
crypto = require('crypto')

MAGIC_STRING = "GyFfJywqgwVcXeY24J"

#
# create a VM session (lab:user@vm_name -i private_key)
#
module.exports.create = (req, res, next) ->
	data = req.body

	unless data.lab? and data.vm_name? and data.user? and data.private_key?
		return res.send 412, 
			reason: "lab, user, vm_name and private_key required."

	session_id = uuid.v4()

	# get the vm
	get_vms data.lab, (err, vm) ->
		if err
			return res.send 417, err

		# TODO generate secret token
		# TODO save to redis
		# TODO store private_key to a file
		# DONE

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

	create_secret = (data, callback) ->
		shasum = crypto.createHash('sha1')
		shasum.update(data)
		shasum.update(MAGIC_STRING)

		callback(shasum.digest('hex'))








