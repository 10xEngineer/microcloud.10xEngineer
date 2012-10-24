module.exports = -> 

restify 	= require("restify")
log 		= require("log4js").getLogger()

module.exports.ping = (req, res, next) ->
	res.send {"status": "ok"}