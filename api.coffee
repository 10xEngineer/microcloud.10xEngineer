log 		= require("log4js").getLogger()
server 		= require("./api/server")
config 		= require "./api/config"
mongoose 	= require "mongoose"
auth 		= require("./utils/auth")

log.info "using mongo=#{config.get('mongodb')}"
mongoose.connect(config.get('mongodb'))

server.setup()

api = server.run(auth, require("./api/utils/auth_helper"))
api.listen 8090