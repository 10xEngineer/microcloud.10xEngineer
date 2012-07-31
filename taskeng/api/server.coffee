restify = require "restify"
log = require("log4js").getLogger()
routes = require "./routes"

module.exports.createServer = (runner) ->
	server = restify.createServer
		name: "api.tasks.10xlabs.net"
		version: "0.1.0"

	server.runner = runner

	server.use restify.acceptParser(server.acceptable)
	server.use restify.dateParser()
	server.use restify.queryParser()
	server.use restify.bodyParser()
	server.use restify.throttle
		burst: 50
		rate: 25
		ip: true

	routes.register server

	server.listen 8000, () ->
		log.info "%s listening at %s", server.name, server.url

	server

