tty = require 'tty.js'
express = require 'express'

app = tty.createServer(
	# TODO specify connect wrapper
	shell: 'bash',
	users: 
		foo: '62cdb7020ff920e5aa642c3d4066950dd1f01f4d'
	port: 9000
)

verify = (user, pass, next) ->
	if user != 'foo' && pass != 'bar'
		return next()

	next null, 'foo'

app.setAuth express.basicAuth(verify)

# basicAuth is part of connect's middleware
# http://www.senchalabs.org/connect/basicAuth.html

# pty.js behind the scene
# https://github.com/chjj/pty.js/

# TODO fork env: process.evn (add '10xlabs indicator')

# TODO tty.shell -> point to ssh_connect.rb
# FIXME how to pass custom arguments to ssh_connect.rb
#       https://githubw.com/chjj/tty.js/blob/master/lib/tty.js#L400


app.on 'session', () ->
	console.log '--- session init'
	

app.get '/foo', (req, res, next) ->
	res.send 'bar'
	
app.listen()
