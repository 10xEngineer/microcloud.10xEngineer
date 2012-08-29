log = require("log4js").getLogger()
restify = require "restify"
ip_auth = require "./ip_auth"

# TODO bind only to specified IP address (bridge interface)
bind_host = "0.0.0.0"

server = restify.createServer()
server.use(ip_auth.ipBasedAuthentication())

client = restify.createJsonClient 
	# FIXME hardcoded; use from hostnode configuration
	url: "http://bunny.laststation.net:8080"
	version: "*"

server.get "/metadata", (req, res, next) ->
	# TODO compile metadata
	client.get "/vms/#{req.vm_uuid}", (err, get_req, get_res, obj) ->
		res.send obj

server.listen 8000, "0.0.0.0", () ->
	console.log "%s listening at %s", server.name, server.url