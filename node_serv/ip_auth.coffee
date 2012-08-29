module.exports = ->

fs = require "fs"


getClientIP = (req) ->
  x_ip = req.headers['x-forwarded-for'] 
  unless x_ip? then x_ip = req.connection.remoteAddress
  x_ip

module.exports.dnsMasqResolver = dnsMasqResolver = (ip_address, callback) ->
	# TODO temporarily using dnsmasq.leases directly
	#      should refactor local VM descriptors and use centralized storage
	#      within node_serv
	vm_uuid = null

	fs.readFile '/var/lib/misc/dnsmasq.leases', (err, data) ->
		if err
			return callback(err)

		leases = data.toString().split("\n")
		leases.forEach (lease, i) ->
			parts = lease.split(' ')

			if parts.length == 5 && parts[2] == ip_address
				vm_uuid = parts[3]

		callback(null, vm_uuid)

module.exports.ipBasedAuthentication = () ->
	# TODO allow pluggable VM UUID resolver (now using hardcoded dnsMasqResolver)
	return (req, res, next) ->
		client_ip = getClientIP(req)

		dnsMasqResolver client_ip, (err, vm_uuid) ->
			unless vm_uuid
				return next(new Error("Uknown VM."))

			req.vm_uuid = vm_uuid

			return next()
