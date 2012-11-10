log 		= require("log4js").getLogger()
restify 	= require("restify")
mongoose 	= require("mongoose")
config 		= require("./config")

module.exports = (auth, auth_helper) ->
	require("./model/microcloud").register()
	require("./model/user").register()
	require("./model/account").register()
	require("./model/access_token").register()
	require("./model/key").register()

	# API server
	server = restify.createServer
		name: "api.10xlabs.net"

	auth.setup server, auth_helper,
		microclouds: 
			url_match: new RegExp("^/microclouds$")
			schema: "none"

	server.use restify.acceptParser(server.acceptable)
	server.use restify.queryParser()
	server.use restify.bodyParser()

	routes = require("./routes")
	routes.register(server)

	server.use restify.conditionalRequest()

	return server
