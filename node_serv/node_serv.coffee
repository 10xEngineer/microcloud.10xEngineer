log = require("log4js").getLogger()
restify = require "restify"
ip_auth = require "./ip_auth"
http = require "http"

# TODO bind only to specified IP address (bridge interface)
bind_host = "0.0.0.0"

server = restify.createServer()
server.use(ip_auth.ipBasedAuthentication())

microcloud = 
	host: "bunny.laststation.net"
	port: 8080

client = restify.createJsonClient 
	# FIXME hardcoded; use from hostnode configuration
	url: "http://#{microcloud.host}:#{microcloud.port}"
	version: "*"

server.get "/metadata", (req, res, next) ->
	# TODO compile metadata
	# TODO add VM data from definition
	client.get "/vms/#{req.vm_uuid}", (err, get_req, get_res, obj) ->
		res.send obj

getLab = (vm_uuid, next) ->
	client.get "/vms/#{vm_uuid}", (err, get_req, get_res, obj) ->
		if err
			return next(err)

		next(null, obj.lab.name)

server.get "/repository", (req, res, next) ->
	getLab req.vm_uuid, (err, lab_name) ->
		options = 
			host: microcloud.host
			port: microcloud.port
			path: "/labs/#{lab_name}/archive"
			method: "GET"

		request = http.request options, (response) ->
			response.on 'data', (chunk) ->
				res.write chunk, 'binary'

			response.on 'end', () ->
				res.end()

		request.end()

server.listen 8000, "0.0.0.0", () ->
	console.log "%s listening at %s", server.name, server.url