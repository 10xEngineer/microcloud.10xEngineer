module.exports = ->

log = require("log4js").getLogger()


#
# 10xLabs event interface
#
module.exports.accept = (req, res, next) ->
	# FIXME not implemented
	res.send {}