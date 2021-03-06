restify = require("restify")
log = require("log4js").getLogger()
nowjs = require("now")
nconf = require("nconf")

routes = require "./routes"
mongoose = require "mongoose"

# configuration support
nconf.env().argv()
nconf.file({file: "server/config.json"})
nconf.defaults({
  'NODE_ENV': 'development'
});

nconf.set('database:host', '127.0.0.1');
nconf.set('database:port', 5984);

# TODO use configuration
mongoose.connect "mongodb://localhost/microcloud_dev"

provider = require "./model/provider"

console.log "NODE_ENV: " + nconf.get("NODE_ENV")
console.log "database:" + nconf.get("database")

i = new Provider
i.name = "test"
i.save (err) ->
  console.log "test"

# Setup the REST API
server = module.exports = restify.createServer(
	name: "microcloud.10xengineer.me"
	version: "0.1.0"
)
server.use restify.acceptParser(server.acceptable)
#server.use restify.authorizationParser()
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
server.use restify.conditionalRequest()

# register the routes with the server
routes.registerRoutes server

# setup the nowjs for notifications
everyone = nowjs.initialize(server)
nowjs.on 'connect', () ->
	this.now.channel = 'channel 1'
	nowjs.getGroup(this.now.channel).addUser(this.user.clientId)
	log 'Joined channel ' + this.now.name

nowjs.on 'disconnect', () ->
	log 'Left channel ' + this.now.name

everyone.now.distributeMessage = (message) ->
	nowjs.getGroup(this.now.channel).now.receiveMessage(this.now.name, message)

server.listen 8080, ->
	console.log "%s listening at %s", server.name, server.url

# ------------------------------------------------------------------------------------
# Return the admin page

server.get
	url: "/admin"
, (req, res, next) ->
	res.render "ADMIN PAGE TO GO HERE"
