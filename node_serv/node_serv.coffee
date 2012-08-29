log = require("log4js").getLogger()
restify = require "restify"
ip_auth = require "./ip_auth"

# TODO bind only to specified IP address (bridge interface)
bind_host = "0.0.0.0"


server = restify.createServer()
server.use(ip_auth.ipBasedAuthentication())

server.get "/metadata", (req, res, next) ->
	res.send req.vm_uuid
			
server.listen 8000, "0.0.0.0", () ->
	console.log "%s listening at %s", server.name, server.url