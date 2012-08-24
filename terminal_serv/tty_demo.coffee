tty = require 'tty.js'
log = require("log4js").getLogger()
express = require 'express'
sessions = require './app/sessions'
mgmt_app = express()

# management interface
# TODO refactor mgmt interface into a module
mgmt_app.use(express.bodyParser())

mgmt_app.post '/sessions', sessions.create
mgmt_app.listen(9001)
console.log "management interface started on port \x1b[1m9001\x1b[m"

#
# tty.js 
#

# https://github.com/senchalabs/connect/blob/master/lib/utils.js#L291
unauthorized = (res, realm) ->
	res.statusCode = 401
	res.setHeader('WWW-Authenticate', 'Basic realm="' + realm + '"')
	res.end('Unauthorized')

app = tty.createServer(
	# TODO specify connect wrapper
	shell: 'bash',
	users: 
		foo: '62cdb7020ff920e5aa642c3d4066950dd1f01f4d'
	port: 9090
)

# TODO lab is identified by name/token
# TODO query microcloud / check local cache
# TODO how to get vm name
labBasicAuth = (callback, realm) ->

myAuth = (callback, realm) ->
	return (req, res, next) ->
		console.log req.socket
		vm_name = req.socket

		console.log '--- my auth process'
		# res == null => socket.io request
		console.log res == null
		console.log req.originalUrl

		authorization = req.headers.authorization;
		next() if req.user

		return unauthorized(res, realm) unless authorization

		authorization = req.headers.authorization;
		parts = authorization.split(' ')

		user = 'foo'
		pass = 'bar'

		callback res == null, user, pass, (err, user, lab) ->
			req.user = req.remoteUser = user

			# TODO user, vm_ip, identity_file, 
			req.config = 
				shell: "/Users/radim/test.sh"
				shellArgs: []

			next()

verify = (is_socket, user, pass, next) ->
	console.log is_socket
	if user != 'foo' && pass != 'bar'
		return next()

	next null, 'foo', 'labxxx'

app.setAuth myAuth(verify)

# basicAuth is part of connect's middleware
# http://www.senchalabs.org/connect/basicAuth.html

# TODO fork env: process.env (add '10xlabs indicator')

# TODO tty.shell -> point to ssh_connect.rb
# FIXME how to pass custom arguments to ssh_connect.rb
#       https://githubw.com/chjj/tty.js/blob/master/lib/tty.js#L400

app.on 'session', () ->
	console.log '--- session init'

# TODO store key
# TODO shell entry -> lab + vm_name + session_id -> 

# TODO skip authentication for /sessions
app.post '/sessions', sessions.create

app.get '/foo', (req, res, next) ->
	res.send 'bar'
	
app.listen()
