module.exports = ->

log = require("log4js").getLogger()
commands = require("./commands")
mongoose = require("mongoose")
Provider = mongoose.model('Provider')
broker = require("../broker")

module.exports.create = (req, res, next) ->
  Provider.findOne {name: req.params.provider}, (err, doc) ->
    # FIXME hardcoded provider and options
    provider = 'vagrant'
    options = {
      env: "/Users/radim/Projects/10xeng/microcloud.10xEngineer/a_vagrant_machine"
    }

    broker.dispatch provider, 'start', options, (message) ->
      res.send message
    
module.exports.show = (req, res, next) ->
  Provider.findOne {name: req.params.provider}, (err, doc) ->
    # FIXME hardcoded provider and options
    provider = 'vagrant'
    options = {
      env: "/Users/radim/Projects/10xeng/microcloud.10xEngineer/a_vagrant_machine"
    }

    broker.dispatch provider, 'status', options, (message) ->
      res.send message

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
