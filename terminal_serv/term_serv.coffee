tty = require 'tty.js'
log = require("log4js").getLogger()
express = require 'express'
sessions = require './app/sessions'
mgmt_app = express()
redis = require("redis")
client = redis.createClient()
http = require("http")
nconf = require("nconf")

# configuration
nconf
	.argv()
	.env()
	.file
		file: "/etc/10xlabs-hostnode.json"

# management interface
# TODO refactor mgmt interface into a module
mgmt_app.use(express.bodyParser())

mgmt_app.post '/sessions', sessions.create
mgmt_app.listen(9001)
console.log "management interface started on port \x1b[1m9001\x1b[m"

#
# tty.js 
#

# https://github.com/senchalabs/connect/blob/master/lib/utils.js
unauthorized = (res, realm) ->
	res.statusCode = 401
	res.setHeader('WWW-Authenticate', 'Basic realm="' + realm + '"')
	res.end('Unauthorized')

error = (code, msg) ->
	err = new Error(msg || http.STATUS_CODES[code])
	err.status = code

	return err

app = tty.createServer(
	port: 9090
)

# TODO lab is identified by name/token
# TODO query microcloud / check local cache
# TODO how to get vm name
labBasicAuth = (callback, realm) ->

labAuth = (callback, realm) ->
	return (req, res, next) ->
		authorization = req.headers.authorization;
		next() if req.user

		return unauthorized(res, realm) unless authorization

		authorization = req.headers.authorization;
		parts = authorization.split(' ')

		return next error(400) if parts.length != 2

		scheme = parts[0]
		credentials = new Buffer(parts[1], 'base64').toString().split(':')
		user = credentials[0]
		pass = credentials[1]

		callback res == null, user, pass, (err, user, lab_data) ->
			if err || !user?
				return unauthorized(res, realm)

			req.user = req.remoteUser = user

			# TODO user, vm_ip, identity_file, 
			req.config = 
				shell: "/Users/radim/test.sh"
				shellArgs: [user, lab_data.user, lab_data.host]

			next()

verify = (is_socket, user, pass, next) ->
	client.hgetall user, (err, data) ->
		if err
			return next(err)

		if data and data.secret == pass
			lab_data = 
				user: data.user
				host: data.host

			return next null, user, lab_data
		else
			return next(true)

app.setAuth labAuth(verify)
app.listen()
