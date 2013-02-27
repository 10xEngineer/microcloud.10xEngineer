log 		= require("log4js").getLogger()
restify 	= require("restify")
mongoose 	= require("mongoose")
config 		= require("./config")
customer_io = require("../utils/customer_io")
				.setupClient("d98bb6ac9f4e37c473b7", "9aa1813a41e948025b76")

module.exports.setup = () ->
	require("./model/microcloud").register()
	require("./model/user").register()
	require("./model/account").register()
	require("./model/access_token").register()
	require("./model/key").register()




module.exports.run = (auth, auth_helper) ->
	# API server
	server = restify.createServer
		name: "api.10xlabs.net"

	# Set default headers
	oldDefaultResponseHeaders = require('http').ServerResponse.prototype.defaultResponseHeaders
	restify.defaultResponseHeaders = (data) ->
		oldDefaultResponseHeaders.call(this, data)
		this.header('Access-Control-Allow-Methods', 'OPTIONS,GET,HEAD,POST,PUT,DELETE,TRACE,CONNECT')
		this.header('Access-Control-Allow-Headers', 'Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version, X-Requested-With, X-Labs-Date, X-Labs-Token, X-Labs-Signature')

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
