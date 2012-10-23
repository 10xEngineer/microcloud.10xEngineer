mongoose = require("mongoose")
log = require("log4js").getLogger()
restify = require("restify")
config = require("./server/config")
auth = require("./server/utils/auth")

# TODO configure mongodb
mongoose.connect('mongodb://'+config.get('mongodb:host')+'/'+config.get('mongodb:dbName'))

server = restify.createServer
	name: "microcloud.10xengineer.me"
	version: "0.1.0"

# model
require("./server/model/hostnode").register
require("./server/model/provider").register
require("./server/model/keypair").register
require("./server/model/vm").register
require("./server/model/lab").register
require("./server/model/definition").register
require("./server/model/pool").register


# routes
routes = require("./server/routes")

server.use restify.acceptParser(server.acceptable)
server.use restify.queryParser()
server.use restify.bodyParser()

auth.setup(server)

# setup routes
routes.registerRoutes server

server.use restify.conditionalRequest()
server.listen config.get('server:port'), ->
	log.info "%s listening at %s", server.name, server.url
