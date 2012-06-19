mongoose = require("mongoose")
log = require("log4js").getLogger()
restify = require("restify")
config = require("./server/config")

# TODO configure mongodb
mongoose.connect('mongodb://'+config.get('mongodb:host')+'/'+config.get('mongodb:dbName'))

server = restify.createServer(
	name: "microcloud.10xengineer.me"
	version: "0.1.0"
)

# model
require("./server/model/provider").register
require("./server/model/hostnode").register
require("./server/model/lab_definition").register

# routes
routes = require("./server/routes")

server.use restify.acceptParser(server.acceptable)
server.use restify.dateParser()
server.use restify.queryParser()
server.use restify.bodyParser()
server.use restify.throttle(
	burst: 100
	rate: 50
	ip: true
	overrides:
		"192.168.1.106":
			rate: 0   #unlimited
			burst: 0

		"127.0.0.1":
			rate: 0   #unlimited
			burst: 0
)

# setup routes
routes.registerRoutes server

server.use restify.conditionalRequest()
server.listen config.get('server:port'), ->
	log.info "%s listening at %s", server.name, server.url
