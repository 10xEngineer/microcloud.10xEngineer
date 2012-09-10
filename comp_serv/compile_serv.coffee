log = require("log4js").getLogger()
nconf = require "nconf"
restify = require "restify"
ssh_exec = require("./utils/ssh").ssh_exec

server = restify.createServer
	name: "compile_service.10xengineer.me"
	version: "0.1.0"

server.get '/ping', (req, res, next) ->
	res.writeHead(200, "Content-Type: text/plain")
	# FIXME hardcoded for testing
	session = ssh_exec "radim@bunny", "ls -l "

	session.on 'data', (data) ->
		res.write(data, 'ascii')

	session.on 'end', () ->
		res.end()

server.listen 8001, () ->
	log.info "#{server.name} listening at port 8001"
