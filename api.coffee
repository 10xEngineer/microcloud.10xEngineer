log 		= require("log4js").getLogger()
restify 	= require("restify")
mongoose 	= require("mongoose")
auth 		= require("./server/utils/auth")

# mongoose
# FIXME configurable
mongoose.connect('mongo://localhost/labs_dev')

require("./api/model/user").register()
require("./api/model/access_token").register()

AccessToken = mongoose.model('AccessToken')
token = new AccessToken
	auth_token: 'xxx'

# API server
server = restify.createServer
	name: "api.10xlabs.net"

#auth.setup(server)

server.use restify.acceptParser(server.acceptable)
server.use restify.queryParser()
server.use restify.bodyParser()

routes = require("./api/routes")
routes.register(server)

server.use restify.conditionalRequest()
server.listen 8090, ->
	log.info "%s listening at %s", server.name, server.url