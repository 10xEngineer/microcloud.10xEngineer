log 		= require("log4js").getLogger()
server 		= require("./api/server")
config 		= require "./api/config"
mongoose 	= require "mongoose"
auth 		= require("../utils/auth")

# FIXME configurable
log.info "using mongo=#{config.get('mongodb')}"
mongoose.connect(config.get('mongodb'))

server(auth, require("./utils/auth_helper")).listen 8090, ->
	log.info "%s listening at %s", server.name, server.url
