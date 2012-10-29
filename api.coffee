log 		= require("log4js").getLogger()
restify 	= require("restify")
mongoose 	= require("mongoose")
auth 		= require("./utils/auth")

# FIXME configurable
mongoose.connect('mongo://localhost/labs_dev')

require("./api/model/microcloud").register()
require("./api/model/user").register()
require("./api/model/account").register()
require("./api/model/access_token").register()
require("./api/model/key").register()

# API server
server = restify.createServer
	name: "api.10xlabs.net"

auth.setup server, require("./api/utils/auth_helper"),
	microclouds: 
		url_match: new RegExp("^/microclouds$")
		schema: "none"

server.use restify.acceptParser(server.acceptable)
server.use restify.queryParser()
server.use restify.bodyParser()

routes = require("./api/routes")
routes.register(server)

server.use restify.conditionalRequest()
server.listen 8090, ->
	log.info "%s listening at %s", server.name, server.url
