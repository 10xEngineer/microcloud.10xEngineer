mongoose 		= require("mongoose")
log 			= require("log4js").getLogger()
restify 		= require("restify")
config 			= require("./server/config")
auth 			= require("./utils/auth")
auth_helper 	= require("./server/utils/auth_helper")
platform_api 	= require("./server/api/platform/client")

# TODO configure mongodb
mongoose.connect('mongodb://'+config.get('mongodb:host')+'/'+config.get('mongodb:dbName'))

server = restify.createServer
	name: "microcloud.10xengineer.me"
	version: "0.1.0"

# setup default Platform API client
platform_api.setup("f933c346c502c11b64164143087f", "55347d223f161014a8659361afe771929f61246d09a3b22f", "http://api.labs.dev/")

# model
require("./server/model/proxy_user").register
require("./server/model/template").register
require("./server/model/node").register
require("./server/model/pool").register
require("./server/model/machine").register

# routes
routes = require("./server/routes")

server.use restify.acceptParser(server.acceptable)
server.use restify.queryParser()
server.use restify.bodyParser()

auth.setup server, 
	ping: 
		url_match: new RegExp("^/ping\\?token\=(.*)")
		schema: "token"
		token: "pYvf8p3LxFnqoAGn"

# setup routes
routes.registerRoutes server

server.use restify.conditionalRequest()
server.listen config.get('server:port'), ->
	log.info "%s listening at %s", server.name, server.url
