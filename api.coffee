log 		= require("log4js").getLogger()
server 		= require("./api/server")
config 		= require "./api/config"
mongoose 	= require "mongoose"
auth 		= require("./utils/auth")
stats		= require("./api/stats")

log.info "using mongo=#{config.get('mongodb')}"
mongoose.connect(config.get('mongodb'))

server.setup()

stats.setup()

api = server.run(auth, require("./api/utils/auth_helper"))
api.listen 8090