log = require("log4js").getLogger()

module.exports.get_ping = (req, res, next) ->
	log.info "ping received."
	res.send pong: true
