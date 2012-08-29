log = require("log4js").getLogger()
restify = require "restify"
fs = require "fs"

# TODO bind only to specified IP address (bridge interface)
bind_host = "0.0.0.0"

getClientIP = (req) ->
  x_ip = req.headers['x-forwarded-for'] 
  unless x_ip? then x_ip = req.connection.remoteAddress
  x_ip

getUUID = (ip_address, callback) ->
	# TODO temporarily using dnsmasq.leases directly
	#      should refactor local VM descriptors and use centralized storage
	#      within node_serv
	fs.readFile '/var/lib/misc/dnsmasq.leases', (err, data) ->
		if err
			return callback(err)

		leases = data.toString().split("\n")
		leases.forEach (lease, i) ->
			parts = lease.split(' ')

			if parts.length == 5 and parts[2] == ip_address
				return callback(null, parts[3])

		callback(null, null)

server = restify.createServer()
server.get "/metadata", (req, res, next) ->
	client_ip = getClientIP(req)

	# TODO translate IP to VM UUID
	getUUID client_ip, (err, vm_uuid) ->
		unless vm_uuid
			return res.send 401, "Sorry, unknown VM."

		res.send 
			uuid: vm_uuid

server.listen 8000, "0.0.0.0", () ->
	console.log "%s listening at %s", server.name, server.url