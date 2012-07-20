module.exports.command = ->

log = require("log4js").getLogger()
ServiceClient = require("../broker").service_client
broker = require("../broker")

pool = module.exports.pool = require("./pool-commands")
nodes = module.exports.nodes = require("./nodes_commands")
notification = module.exports.notifications = require("./notifications_commands")
providers = module.exports.providers = require("./providers_commands")
vms = module.exports.vms = require("./vms_commands")
labs = module.exports.labs = require("./labs_commands")

events = module.exports.events = require("./events_commands")

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


