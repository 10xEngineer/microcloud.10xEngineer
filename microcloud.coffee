mongoose = require("mongoose")
log = require("log4js").getLogger()
restify = require("restify")
config = require("nconf")

#
# misc TODOs
# TODO valid content types (accepts)
# TODO providers - responses should be improved / standardized
# TODO zmq timeouts

# initialize config
config.argv.env
config.file({file: "config/config.json"})

config.defaults({
  'NODE_ENV': 'development',
  'broker': 'ipc:///tmp/mc.broker'
})

# TODO configure mongodb
mongoose.connect('mongodb://localhost/microcloud_dev')

server = restify.createServer(
  name: "microcloud.10xengineer.me"
  version: "0.1.0"
)

# model
require("./server/model/provider").register

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
server.listen 8080, ->
  log.info "%s listening at %s", server.name, server.url
