module.exports.command = ->

log = require("log4js").getLogger()
ServiceClient = require("../broker").service_client
broker = require("../broker")

cli = module.exports.cli = require("./cli-commands")
pool = module.exports.pool = require("./pool-commands")
server = module.exports.server = require("./server-commands")
container = module.exports.container = require("./container-commands")
notification = module.exports.notifications = require("./notification-commands")
providers = module.exports.providers = require("./providers_commands")
labs = module.exports.labs = require("./labs_commands")

# --------------------------------------------------------------------------------------------------------------------------------------------------------
#
#  Heartbeat
#
# =========================================================================================================================================================

module.exports.get_ping = (req, res, next) ->
	log.info "ping received."
	res.send pong: true

module.exports.post_ping = (req, res, next) ->
	log.info "ping _post_ received"
	res.send 200, {}, req.data

module.exports.broker_ping = (req, res, next) ->
	broker.dispatch 'dummy','ping', {}, (message) ->
		res.send message

module.exports.test_cli_exec = (req, res, next) ->
	log.info "running ls -l to test the cli command interface."
	child = cli.execute_command("localhost", "ls", [ "-lh", "/usr" ], (output) ->
		res.send output
	)
	child.stdout.on "data", (data) ->
		res.send data

	child.stderr.on "data", (data) ->
		res.send data

	child.on "exit", (code) ->
		child.stdin.end()

	next()

# --------------------------------------------------------------------------------------------------------------------------------------------------------
#
#  Test CLI commands
#
# =========================================================================================================================================================

module.exports.test_cli_spawn = (req, res, next) ->
	log.info "running top to test the cli command interface."
	child = cli.spawn_command("localhost", "top", [])
	child.stdout.on "data", (data) ->
		res.send data

	child.stderr.on "data", (data) ->
		res.send data

	child.on "exit", (code) ->
		child.stdin.end()

	next()
