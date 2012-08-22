tty = require 'tty.js'
express = require 'express'


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
	port: 9000
)

# TODO lab is identified by name/token
# TODO query microcloud / check local cache
# TODO how to get vm name
labBasicAuth = (callback, realm) ->

myAuth = (callback, realm) ->
	console.log '-- my auth'
	return (req, res, next) ->
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

			req.config = 
				shell: "/Users/radim/test.sh"
				shellArgs: []

			next()

verify = (is_socket, user, pass, next) ->
	console.log '-- verify'
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

app.get '/foo', (req, res, next) ->
	res.send 'bar'
	
app.listen()
