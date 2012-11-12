mongoose 		= require("mongoose")
log 			= require("log4js").getLogger()
restify 		= require("restify")
config 			= require("./server/config")
auth 			= require("./utils/auth")
platform_api 	= require("./server/api/platform/client")
stats 			= require("./server/stats")

# TODO configure mongodb
mongoose.connect(config.get('mongodb'))

server = restify.createServer
	name: "microcloud.10xengineer.me"
	version: "0.1.0"

# setup default Platform API client
platform_api.setup(
	config.get("platform:token"), 
	config.get("platform:secret"),
	config.get("platform:url"))

# model
require("./server/model/proxy_user").register
require("./server/model/template").register
require("./server/model/node").register
require("./server/model/pool").register
require("./server/model/machine").register
require("./server/model/snapshot").register

# librato metrics
stats.setup()

# routes
routes = require("./server/routes")

server.use restify.acceptParser(server.acceptable)
server.use restify.queryParser()
server.use restify.bodyParser()

auth.setup server, require("./server/utils/auth_helper"),
	ping: 
		url_match: new RegExp("^/ping\\?token\=(.*)")
		schema: "token"
		token: "pYvf8p3LxFnqoAGn"
	proxy_users:
		url_match: new RegExp("^/proxy_users/.*\\?token\=(.*)")
		schema: "token"
		token: "MnMFqjHo368Pmf2R"
	gecko_widget:
		url_match: new RegExp("^/stats/gecko\\?token\=(.*)")
		schema: "token"
		token: "3Kqd3fYTh9K3bXEp"

server.use stats.api_calls_log

# setup routes
routes.registerRoutes server

server.use restify.conditionalRequest()

server.listen config.get('server:port'), ->
	log.info "%s listening at %s", server.name, server.url
