module.exports = ->

log = require("log4js").getLogger()
commands = require("./commands")

# ==================================================================================================================================
module.exports.start = (req, res, next) ->
	log.info "starting a server on : " + req.params.destination
	child = commands.cli.execute_command("localhost", "./scripts/startserver.sh", [ req.params.destination ], (output) ->
		res.send output
	)
	child.stdout.on "data", (data) ->
		log.debug data

	child.stderr.on "data", (data) ->
		log.debug data

	child.on "exit", (code) ->
		log.debug "exiting startserver.sh"
		child.stdin.end()

	next()

# ==================================================================================================================================
module.exports.stop = (req, res, next) ->
	log.info "stopping a server " + req.params.server + " on : " + req.params.destination
	child = commands.cli.execute_command("localhost", "./scripts/stopserver.sh", [ req.params.destination ], (output) ->
		res.send output
	)
	child.stdout.on "data", (data) ->
		log.debug data

	child.stderr.on "data", (data) ->
		log.debug data

	child.on "exit", (code) ->
		log.debug "exiting stopserver.sh"
		child.stdin.end()

	next()

# ==================================================================================================================================
module.exports.status = (req, res, next) ->
	log.info "stopping a server " + req.params.server + " on : " + req.params.destination
	child = commands.cli.execute_command("localhost", "./scripts/getstatusserver.sh", [ req.params.destination ], (output) ->
		res.send output
	)
	child.stdout.on "data", (data) ->
		log.debug data

	child.stderr.on "data", (data) ->
		log.debug data

	child.on "exit", (code) ->
		log.debug "exiting stopserver.sh"
		child.stdin.end()

	next()

# ==================================================================================================================================
module.exports.restart = (req, res, next) ->
	log.info "restarting a server " + req.params.server + " on : " + req.params.destination
	child = commands.cli.execute_command("localhost", "./scripts/restartserver.sh", [ req.params.destination ])
	child.stdout.on "data", (data) ->
		log.debug data

	child.stderr.on "data", (data) ->
		log.debug data

	child.on "exit", (code) ->
		log.debug "exiting stopserver.sh"
		child.stdin.end()

	next()
